# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'open3'
require 'tempfile'

class FetchBackendOpenapiTest < Minitest::Test
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def test_fetches_openapi_document_from_local_source
    Tempfile.create(['source-openapi', '.json']) do |source|
      source.write(JSON.generate('openapi' => '3.0.1', 'paths' => {}))
      source.close

      Tempfile.create(['target-openapi', '.json']) do |target|
        target.close
        File.delete(target.path)

        env = {
          'BACKEND_OPENAPI_URL' => source.path,
          'BACKEND_OPENAPI_PATH' => target.path
        }

        _stdout, stderr, status = Open3.capture3(env, 'bin/fetch-backend-openapi')

        assert status.success?, stderr
        assert_equal JSON.parse(File.read(source.path)), JSON.parse(File.read(target.path))
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
