# frozen_string_literal: true

require 'json'

# Compares two OpenAPI specs and drafts changelog entries for data/changelog.yml.
#
# Step 1: flatten each spec into "facts". A fact is one thing the spec says,
#         for example "GET /api/a has a query parameter called status".
# Step 2: compare the facts of the old spec with the facts of the new spec.
# Step 3: turn each difference into an entry (type + one sentence).
#
# The spec only shows its own shape. A change in behaviour that does not change
# the spec is not found here. A person adds those entries by hand.
module SpecChangelog
  HTTP_METHODS = %w[get post put patch delete].freeze
  MAX_SCHEMA_DEPTH = 12
  MAX_REFERENCE_HOPS = 10
  MAX_ENDPOINTS_LISTED = 5
  TYPE_ORDER = %w[breaking deprecated added].freeze

  DRAFT_COMMENT = '# DRAFT: generated from an OpenAPI spec diff. Check each entry, ' \
                  'edit it, then delete this line.'

  # A fact is a key (array) that maps to a value. The key says what the fact is:
  #   [:endpoint,       'GET /api/a']
  #   [:deprecated,     'GET /api/a']
  #   [:parameter,      'GET /api/a', 'query status']          => required (true/false)
  #   [:parameter_enum, 'GET /api/a', 'query status', 'open']
  #   [:field,          'GET /api/a', 'data[].id']
  #   [:field_enum,     'GET /api/a', 'data[].type', 'thing']
  def self.facts(spec)
    facts = {}
    spec.fetch('paths', {}).each do |path, path_item|
      HTTP_METHODS.each do |http_method|
        operation = path_item[http_method]
        next if operation.nil?

        label = "#{http_method.upcase} #{path}"
        facts[[:endpoint, label]] = true
        facts[[:deprecated, label]] = true if operation['deprecated']
        add_parameter_facts(facts, spec, label, path_item, operation)
        add_response_facts(facts, spec, label, operation)
      end
    end
    facts
  end

  def self.add_parameter_facts(facts, spec, label, path_item, operation)
    parameters = {}
    (path_item['parameters'].to_a + operation['parameters'].to_a).each do |raw_parameter|
      parameter = resolve(raw_parameter, spec)
      parameters["#{parameter['in']} #{parameter['name']}"] = parameter
    end

    parameters.each do |name, parameter|
      facts[[:parameter, label, name]] = parameter['required'] == true
      parameter.dig('schema', 'enum').to_a.each do |value|
        facts[[:parameter_enum, label, name, value.to_s]] = true
      end
    end
  end

  def self.add_response_facts(facts, spec, label, operation)
    operation.fetch('responses', {}).each do |status_code, raw_response|
      next unless status_code.to_s.start_with?('2')

      schema = resolve(raw_response, spec).dig('content', 'application/json', 'schema')
      next if schema.nil?

      add_schema_facts(facts, spec, label, schema)
    end
  end

  # Walks a schema with an explicit stack, not recursion. The depth limit stops
  # a schema that refers to itself.
  def self.add_schema_facts(facts, spec, label, schema)
    stack = [[schema, '', 0]]
    until stack.empty?
      raw_node, location, depth = stack.pop
      next if depth > MAX_SCHEMA_DEPTH

      node = resolve(raw_node, spec)
      node['enum'].to_a.each { |value| facts[[:field_enum, label, location, value.to_s]] = true }

      node.fetch('properties', {}).each do |name, property|
        field = location.empty? ? name : "#{location}.#{name}"
        facts[[:field, label, field]] = true
        stack.push([property, field, depth + 1])
      end
      stack.push([node['items'], "#{location}[]", depth + 1]) if node['items']
      %w[oneOf anyOf allOf].each do |keyword|
        node[keyword].to_a.each { |member| stack.push([member, location, depth + 1]) }
      end
    end
  end

  # Follows "$ref" links such as '#/components/schemas/Thing'. Returns {} when
  # the link is broken so one bad link cannot stop the whole run.
  def self.resolve(node, spec)
    return {} unless node.is_a?(Hash)

    hops = 0
    while node.is_a?(Hash) && node['$ref'] && hops < MAX_REFERENCE_HOPS
      node = spec.dig(*node['$ref'].delete_prefix('#/').split('/'))
      hops += 1
    end
    node.is_a?(Hash) ? node : {}
  end

  # Returns entries like { type: 'added', description: 'Endpoint `GET /a` added.' }.
  # Entries are sorted breaking first, then deprecated, then added.
  def self.changes(old_spec, new_spec)
    old_facts = facts(old_spec)
    new_facts = facts(new_spec)
    changed_endpoints = changed_endpoint_labels(old_facts, new_facts)

    added_keys = new_facts.keys - old_facts.keys
    removed_keys = old_facts.keys - new_facts.keys

    raw_changes = []
    raw_changes.concat(direction_changes(added_keys, changed_endpoints, new_facts, :added))
    raw_changes.concat(direction_changes(removed_keys, changed_endpoints, old_facts, :removed))
    raw_changes.concat(requirement_changes(old_facts, new_facts, changed_endpoints))
    group(raw_changes)
  end

  def self.changed_endpoint_labels(old_facts, new_facts)
    old_endpoints = old_facts.keys.select { |key| key.first == :endpoint }.map { |key| key[1] }
    new_endpoints = new_facts.keys.select { |key| key.first == :endpoint }.map { |key| key[1] }
    (old_endpoints - new_endpoints) | (new_endpoints - old_endpoints)
  end

  # Turns facts that appeared (or disappeared) into raw changes:
  # { type:, subject:, verb:, endpoint: }
  # It skips facts that a bigger entry already covers:
  # - everything on an endpoint that was added or removed
  # - an enum value or child field when its parent field or parameter changed too
  def self.direction_changes(keys, changed_endpoints, facts, direction)
    keys.filter_map do |key|
      kind, label, *rest = key
      next if kind != :endpoint && changed_endpoints.include?(label)
      next if covered_by_parent?(key, keys)

      type = direction == :added ? added_type(kind, facts[key]) : removed_type(kind)
      next if type.nil?

      verb = direction == :removed ? 'removed' : added_verb(kind)
      { type: type, subject: subject_for(kind, label, rest), verb: verb, endpoint: label }
    end
  end

  def self.requirement_changes(old_facts, new_facts, changed_endpoints)
    (old_facts.keys & new_facts.keys).filter_map do |key|
      kind, label, *rest = key
      next if kind != :parameter || changed_endpoints.include?(label)
      next if old_facts[key] == new_facts[key]

      now_required = new_facts[key]
      {
        type: now_required ? 'breaking' : 'added',
        subject: subject_for(kind, label, rest),
        verb: now_required ? 'now required' : 'now optional',
        endpoint: label
      }
    end
  end

  def self.covered_by_parent?(key, same_direction_keys)
    kind, label, location = key
    case kind
    when :parameter_enum then same_direction_keys.include?([:parameter, label, location])
    when :field_enum then field_or_ancestor_in?(label, location, same_direction_keys, include_self: true)
    when :field then field_or_ancestor_in?(label, location, same_direction_keys, include_self: false)
    else false
    end
  end

  def self.field_or_ancestor_in?(label, location, keys, include_self:)
    return true if include_self && keys.include?([:field, label, location])

    keys.any? do |other|
      other_kind, other_label, other_location = other
      other_kind == :field && other_label == label &&
        (location.start_with?("#{other_location}.") || location.start_with?("#{other_location}[]"))
    end
  end

  def self.added_type(kind, new_value)
    return 'deprecated' if kind == :deprecated
    return 'breaking' if kind == :parameter && new_value == true

    'added'
  end

  def self.removed_type(kind)
    kind == :deprecated ? nil : 'breaking'
  end

  def self.added_verb(kind)
    kind == :deprecated ? 'deprecated' : 'added'
  end

  def self.subject_for(kind, label, rest)
    case kind
    when :endpoint, :deprecated then "Endpoint `#{label}`"
    when :parameter then parameter_subject(rest.first)
    when :parameter_enum then "#{parameter_subject(rest.first)} value `#{rest.last}`"
    when :field then "Response field `#{display_field(rest.first)}`"
    when :field_enum then "Response field `#{display_field(rest.first)}` value `#{rest.last}`"
    end
  end

  # Every v2 response wraps its content in "data". Drop that wrapper so the list
  # and the detail endpoint of one resource give the same field name.
  def self.display_field(location)
    location.sub(/\Adata(\[\])?\./, '')
  end

  def self.parameter_subject(location_and_name)
    location, name = location_and_name.split(' ', 2)
    "#{location.capitalize} parameter `#{name}`"
  end

  # Joins changes that say the same thing about different endpoints, so a field
  # added to a shared schema gives one entry, not one per endpoint.
  def self.group(raw_changes)
    grouped = raw_changes.group_by { |change| [change[:type], change[:subject], change[:verb]] }
    entries = grouped.map do |(type, subject, verb), members|
      { type: type, description: describe(subject, verb, members.map { |member| member[:endpoint] }) }
    end

    entries.sort_by.with_index { |entry, index| [TYPE_ORDER.index(entry[:type]), index] }
  end

  def self.describe(subject, verb, endpoints)
    return "#{subject} #{verb}." if subject.start_with?('Endpoint')

    unique = endpoints.uniq
    where = if unique.length > MAX_ENDPOINTS_LISTED
              "#{unique.length} endpoints"
            else
              unique.map { |endpoint| "`#{endpoint}`" }.join(', ')
            end
    "#{subject} #{verb} on #{where}."
  end

  # Puts a draft block of entries above the existing entries and keeps the file
  # header. Returns the text unchanged when there are no entries.
  def self.prepend(existing_yaml, entries, date)
    return existing_yaml if entries.empty?

    block = +"#{DRAFT_COMMENT}\n"
    entries.each do |entry|
      block << "- date: #{date.iso8601}\n"
      block << "  type: #{entry[:type]}\n"
      block << "  description: #{entry[:description].to_json}\n\n"
    end

    first_entry = existing_yaml.index(/^- date:/)
    return existing_yaml + "\n" + block if first_entry.nil?

    existing_yaml.dup.insert(first_entry, block)
  end
end
