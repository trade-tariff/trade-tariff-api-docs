# frozen_string_literal: true

require 'minitest/autorun'
require 'yaml'
require 'date'
require_relative '../lib/spec_changelog'

class SpecChangelogTest < Minitest::Test
  def operation(parameters: [], fields: {}, deprecated: false)
    properties = fields.transform_values { |type| { 'type' => type } }
    operation = {
      'parameters' => parameters,
      'responses' => {
        '200' => {
          'content' => { 'application/json' => { 'schema' => { 'type' => 'object', 'properties' => properties } } }
        }
      }
    }
    operation['deprecated'] = true if deprecated
    operation
  end

  def spec(paths, components = {})
    { 'openapi' => '3.0.1', 'paths' => paths, 'components' => components }
  end

  def query_parameter(name, required: false, enum: nil)
    schema = { 'type' => 'string' }
    schema['enum'] = enum if enum
    { 'name' => name, 'in' => 'query', 'required' => required, 'schema' => schema }
  end

  def changes(old_spec, new_spec)
    SpecChangelog.changes(old_spec, new_spec)
  end

  def test_no_entries_when_nothing_changed
    same = spec('/api/a' => { 'get' => operation(fields: { 'id' => 'string' }) })

    assert_empty changes(same, same)
  end

  def test_added_endpoint_is_added_and_hides_its_own_fields
    old_spec = spec({})
    new_spec = spec('/api/a' => { 'get' => operation(fields: { 'id' => 'string' }) })

    assert_equal [{ type: 'added', description: 'Endpoint `GET /api/a` added.' }], changes(old_spec, new_spec)
  end

  def test_removed_endpoint_is_breaking
    old_spec = spec('/api/a' => { 'get' => operation })
    new_spec = spec({})

    assert_equal [{ type: 'breaking', description: 'Endpoint `GET /api/a` removed.' }], changes(old_spec, new_spec)
  end

  def test_optional_parameter_added_is_added
    old_spec = spec('/api/a' => { 'get' => operation })
    new_spec = spec('/api/a' => { 'get' => operation(parameters: [query_parameter('status')]) })

    assert_equal [{ type: 'added', description: 'Query parameter `status` added on `GET /api/a`.' }],
                 changes(old_spec, new_spec)
  end

  def test_required_parameter_added_is_breaking
    old_spec = spec('/api/a' => { 'get' => operation })
    new_spec = spec('/api/a' => { 'get' => operation(parameters: [query_parameter('status', required: true)]) })

    assert_equal [{ type: 'breaking', description: 'Query parameter `status` added on `GET /api/a`.' }],
                 changes(old_spec, new_spec)
  end

  def test_parameter_removed_is_breaking
    old_spec = spec('/api/a' => { 'get' => operation(parameters: [query_parameter('status')]) })
    new_spec = spec('/api/a' => { 'get' => operation })

    assert_equal [{ type: 'breaking', description: 'Query parameter `status` removed on `GET /api/a`.' }],
                 changes(old_spec, new_spec)
  end

  def test_parameter_becoming_required_is_breaking_and_becoming_optional_is_added
    optional = spec('/api/a' => { 'get' => operation(parameters: [query_parameter('status')]) })
    required = spec('/api/a' => { 'get' => operation(parameters: [query_parameter('status', required: true)]) })

    assert_equal [{ type: 'breaking', description: 'Query parameter `status` now required on `GET /api/a`.' }],
                 changes(optional, required)
    assert_equal [{ type: 'added', description: 'Query parameter `status` now optional on `GET /api/a`.' }],
                 changes(required, optional)
  end

  def test_parameter_enum_value_added_and_removed
    old_spec = spec('/api/a' => { 'get' => operation(parameters: [query_parameter('status', enum: %w[open])]) })
    new_spec = spec('/api/a' => { 'get' => operation(parameters: [query_parameter('status', enum: %w[suspended])]) })

    assert_equal [
      { type: 'breaking', description: 'Query parameter `status` value `open` removed on `GET /api/a`.' },
      { type: 'added', description: 'Query parameter `status` value `suspended` added on `GET /api/a`.' }
    ], changes(old_spec, new_spec)
  end

  def test_response_field_added_and_removed
    old_spec = spec('/api/a' => { 'get' => operation(fields: { 'id' => 'string', 'old' => 'string' }) })
    new_spec = spec('/api/a' => { 'get' => operation(fields: { 'id' => 'string', 'new' => 'string' }) })

    assert_equal [
      { type: 'breaking', description: 'Response field `old` removed on `GET /api/a`.' },
      { type: 'added', description: 'Response field `new` added on `GET /api/a`.' }
    ], changes(old_spec, new_spec)
  end

  def test_newly_deprecated_operation
    old_spec = spec('/api/a' => { 'get' => operation })
    new_spec = spec('/api/a' => { 'get' => operation(deprecated: true) })

    assert_equal [{ type: 'deprecated', description: 'Endpoint `GET /api/a` deprecated.' }],
                 changes(old_spec, new_spec)
  end

  def test_same_field_added_on_two_endpoints_is_one_entry
    old_spec = spec('/api/a' => { 'get' => operation }, '/api/b' => { 'get' => operation })
    new_spec = spec('/api/a' => { 'get' => operation(fields: { 'roles' => 'array' }) },
                    '/api/b' => { 'get' => operation(fields: { 'roles' => 'array' }) })

    assert_equal [{ type: 'added', description: 'Response field `roles` added on `GET /api/a`, `GET /api/b`.' }],
                 changes(old_spec, new_spec)
  end

  def test_many_endpoints_are_counted_not_listed
    paths = (1..7).to_h { |number| ["/api/#{number}", { 'get' => operation }] }
    with_field = (1..7).to_h { |number| ["/api/#{number}", { 'get' => operation(fields: { 'roles' => 'array' }) }] }

    assert_equal [{ type: 'added', description: 'Response field `roles` added on 7 endpoints.' }],
                 changes(spec(paths), spec(with_field))
  end

  def test_path_level_and_referenced_parameters_are_included
    shared = { 'name' => 'as_of', 'in' => 'query', 'required' => false, 'schema' => { 'type' => 'string' } }
    components = { 'parameters' => { 'as_of' => shared } }
    old_spec = spec({ '/api/a' => { 'get' => operation } }, components)
    new_spec = spec({ '/api/a' => { 'parameters' => [{ '$ref' => '#/components/parameters/as_of' }],
                                    'get' => operation } }, components)

    assert_equal [{ type: 'added', description: 'Query parameter `as_of` added on `GET /api/a`.' }],
                 changes(old_spec, new_spec)
  end

  def test_nested_and_referenced_schema_fields_are_included
    response_schema = {
      'type' => 'object',
      'properties' => { 'data' => { 'type' => 'array', 'items' => { '$ref' => '#/components/schemas/Thing' } } }
    }
    response = { '200' => { 'content' => { 'application/json' => { 'schema' => response_schema } } } }
    build = lambda { |fields|
      thing = { 'type' => 'object', 'properties' => fields.to_h { |field| [field, { 'type' => 'string' }] } }
      spec({ '/api/a' => { 'get' => { 'responses' => response } } }, { 'schemas' => { 'Thing' => thing } })
    }

    assert_equal [{ type: 'added', description: 'Response field `roles` added on `GET /api/a`.' }],
                 changes(build.call(%w[id]), build.call(%w[id roles]))
  end

  def test_new_field_hides_its_enum_values_and_children
    old_spec = spec('/api/a' => { 'get' => operation(fields: { 'data' => 'object' }) })
    roles = { 'type' => 'array', 'items' => { 'type' => 'string', 'enum' => %w[one two] } }
    attributes = { 'type' => 'object', 'properties' => { 'roles' => roles, 'name' => { 'type' => 'string' } } }
    schema = { 'type' => 'object', 'properties' => { 'data' => { 'type' => 'object',
                                                                   'properties' => { 'attributes' => attributes } } } }
    response = { '200' => { 'content' => { 'application/json' => { 'schema' => schema } } } }
    new_spec = spec('/api/a' => { 'get' => { 'responses' => response } })

    assert_equal [{ type: 'added', description: 'Response field `attributes` added on `GET /api/a`.' }],
                 changes(old_spec, new_spec)
  end

  def test_new_parameter_hides_its_enum_values
    old_spec = spec('/api/a' => { 'get' => operation })
    new_spec = spec('/api/a' => { 'get' => operation(parameters: [query_parameter('status', enum: %w[open])]) })

    assert_equal [{ type: 'added', description: 'Query parameter `status` added on `GET /api/a`.' }],
                 changes(old_spec, new_spec)
  end

  def test_data_wrapper_is_dropped_so_list_and_detail_endpoints_group
    list_schema = { 'type' => 'object', 'properties' => { 'data' => { 'type' => 'array', 'items' => {
      'type' => 'object', 'properties' => { 'roles' => { 'type' => 'string' } } } } } }
    detail_schema = { 'type' => 'object', 'properties' => { 'data' => {
      'type' => 'object', 'properties' => { 'roles' => { 'type' => 'string' } } } } }
    respond = ->(schema) { { '200' => { 'content' => { 'application/json' => { 'schema' => schema } } } } }
    old_spec = spec('/api/a' => { 'get' => operation(fields: { 'data' => 'array' }) },
                    '/api/a/{id}' => { 'get' => operation(fields: { 'data' => 'object' }) })
    new_spec = spec('/api/a' => { 'get' => { 'responses' => respond.call(list_schema) } },
                    '/api/a/{id}' => { 'get' => { 'responses' => respond.call(detail_schema) } })

    assert_equal [{ type: 'added',
                    description: 'Response field `roles` added on `GET /api/a`, `GET /api/a/{id}`.' }],
                 changes(old_spec, new_spec)
  end

  def test_circular_references_terminate
    loop_schema = { '$ref' => '#/components/schemas/Node' }
    components = { 'schemas' => { 'Node' => { 'type' => 'object', 'properties' => { 'child' => loop_schema } } } }
    response = { '200' => { 'content' => { 'application/json' => { 'schema' => loop_schema } } } }
    circular = spec({ '/api/a' => { 'get' => { 'responses' => response } } }, components)

    assert_empty changes(circular, circular)
  end

  def test_prepend_puts_a_draft_block_before_existing_entries_and_keeps_the_header
    existing = <<~YAML
      # Header comment

      - date: 2026-09-29
        type: breaking
        description: >-
          Old entry.
    YAML
    entries = [{ type: 'added', description: 'Response field `roles` added on `GET /api/a`.' }]

    result = SpecChangelog.prepend(existing, entries, Date.new(2026, 10, 13))
    parsed = YAML.safe_load(result, permitted_classes: [Date])

    assert_includes result, '# Header comment'
    assert_includes result, '# DRAFT'
    assert_equal [Date.new(2026, 10, 13), Date.new(2026, 9, 29)], parsed.map { |entry| entry['date'] }
    assert_equal 'added', parsed.first['type']
    assert_equal 'Response field `roles` added on `GET /api/a`.', parsed.first['description']
  end

  def test_prepend_leaves_the_file_alone_when_there_are_no_entries
    existing = "- date: 2026-09-29\n  type: added\n  description: Old.\n"

    assert_equal existing, SpecChangelog.prepend(existing, [], Date.new(2026, 10, 13))
  end
end
