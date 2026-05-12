# frozen_string_literal: true

require 'json'

# rubocop:disable Metrics/AbcSize, Metrics/ClassLength, Metrics/MethodLength
# Renders API reference Markdown from the backend OpenAPI JSON document.
class OpenapiReferenceRenderer
  HTTP_METHODS = %w[get put post delete options head patch trace].freeze

  def self.render(path)
    new(JSON.parse(File.read(path))).render
  end

  def initialize(openapi)
    @openapi = openapi
  end

  def render
    sections = []

    sections << "# #{info.fetch('title', 'Trade Tariff Public API')}"
    sections << normalize(info['description']) if present?(info['description'])
    sections << base_urls_section
    sections << endpoints_section
    sections << schemas_section if schemas.any?

    sections.compact.join("\n\n")
  end

  private

  attr_reader :openapi

  def info
    openapi.fetch('info', {})
  end

  def paths
    openapi.fetch('paths', {})
  end

  def schemas
    openapi.dig('components', 'schemas') || {}
  end

  def base_urls_section
    servers = Array(openapi['servers']).filter_map { |server| server['url'] }

    return if servers.empty?

    [
      '## Base URL',
      servers.map { |url| "- `#{url}`" }.join("\n")
    ].join("\n\n")
  end

  def endpoints_section
    operations = paths.flat_map do |path, path_item|
      HTTP_METHODS.filter_map do |method|
        operation = path_item[method]
        next unless operation

        [path, path_item, method, operation]
      end
    end

    grouped_operations = operations.group_by do |_path, _path_item, _method, operation|
      Array(operation['tags']).first || 'Endpoints'
    end

    [
      '## Endpoints',
      grouped_operations.map { |tag, entries| endpoint_group(tag, entries) }.join("\n\n")
    ].join("\n\n")
  end

  def endpoint_group(tag, entries)
    [
      "### #{tag}",
      entries.map { |path, path_item, method, operation| endpoint(path, path_item, method, operation) }.join("\n\n")
    ].join("\n\n")
  end

  def endpoint(path, path_item, method, operation)
    parts = []
    parts << "#### #{operation['summary']}" if present?(operation['summary'])
    parts << "**#{method.upcase} #{path}**"
    parts << normalize(operation['description']) if present?(operation['description'])
    parts << parameters_table(Array(path_item['parameters']) + Array(operation['parameters']))
    parts << responses_table(operation.fetch('responses', {}))

    parts.compact.join("\n\n")
  end

  def parameters_table(parameters)
    return if parameters.empty?

    rows = parameters.map do |parameter|
      [
        parameter['name'],
        parameter['in'],
        parameter['required'] ? 'Yes' : 'No',
        schema_summary(parameter['schema']),
        parameter['description']
      ].map { |value| table_cell(value) }
    end

    markdown_table(%w[Name In Required Type Description], rows)
  end

  def responses_table(responses)
    return if responses.empty?

    rows = responses.map do |status, response|
      [
        status,
        response['description'],
        response_schema_summary(response)
      ].map { |value| table_cell(value) }
    end

    markdown_table(%w[Status Description Schema], rows)
  end

  def response_schema_summary(response)
    content = response['content'] || {}
    schema = content.values.filter_map { |media_type| media_type['schema'] }.first

    schema_summary(schema)
  end

  def schemas_section
    [
      '## Schemas',
      schemas.map { |name, schema| schema_section(name, schema) }.join("\n\n")
    ].join("\n\n")
  end

  def schema_section(name, schema)
    [
      "### #{name}",
      "```json\n#{JSON.pretty_generate(schema)}\n```"
    ].join("\n\n")
  end

  def schema_summary(schema)
    return '' unless schema
    return "`#{schema['$ref']}`" if schema['$ref']

    type = schema['type'] || 'object'

    return "array of #{schema_summary(schema['items'])}" if type == 'array' && schema['items']

    type
  end

  def markdown_table(headers, rows)
    [
      "| #{headers.join(' | ')} |",
      "| #{headers.map { '---' }.join(' | ')} |",
      rows.map { |row| "| #{row.join(' | ')} |" }
    ].flatten.join("\n")
  end

  def table_cell(value)
    normalize(value).gsub('|', '\\|')
  end

  def normalize(value)
    value.to_s.gsub(/\s+/, ' ').strip
  end

  def present?(value)
    !normalize(value).empty?
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/ClassLength, Metrics/MethodLength
