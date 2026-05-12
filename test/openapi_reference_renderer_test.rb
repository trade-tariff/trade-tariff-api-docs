# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'tempfile'

require_relative '../lib/openapi_reference_renderer'

class OpenapiReferenceRendererTest < Minitest::Test
  # rubocop:disable Metrics/MethodLength
  def test_renders_reference_markdown_from_openapi_document
    openapi = {
      'openapi' => '3.0.1',
      'info' => {
        'title' => 'Trade Tariff Public API V2',
        'description' => 'Public tariff data.'
      },
      'servers' => [
        { 'url' => 'https://api.trade-tariff.service.gov.uk/uk/api' }
      ],
      'paths' => {
        '/sections' => {
          'get' => {
            'summary' => 'Lists sections',
            'description' => 'Returns all Tariff sections.',
            'parameters' => [
              {
                'name' => 'filter',
                'in' => 'query',
                'required' => false,
                'schema' => { 'type' => 'string' },
                'description' => 'Filter by section title.'
              }
            ],
            'responses' => {
              '200' => {
                'description' => 'Sections returned.',
                'content' => {
                  'application/json' => {
                    'schema' => { '$ref' => '#/components/schemas/SectionList' }
                  }
                }
              }
            }
          }
        }
      },
      'components' => {
        'schemas' => {
          'SectionList' => {
            'type' => 'object',
            'properties' => {
              'data' => { 'type' => 'array' }
            }
          }
        }
      }
    }

    Tempfile.create(['openapi', '.json']) do |file|
      file.write(JSON.pretty_generate(openapi))
      file.close

      markdown = OpenapiReferenceRenderer.render(file.path)

      assert_includes markdown, '# Trade Tariff Public API V2'
      assert_includes markdown, 'Public tariff data.'
      assert_includes markdown, '**GET /sections**'
      assert_includes markdown, '| filter | query | No | string | Filter by section title. |'
      assert_includes markdown, '| 200 | Sections returned. | `#/components/schemas/SectionList` |'
      assert_includes markdown, '## Schemas'
      assert_includes markdown, '### SectionList'
    end
  end
  # rubocop:enable Metrics/MethodLength
end
