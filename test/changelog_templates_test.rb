# frozen_string_literal: true

require 'minitest/autorun'
require 'erb'
require 'json'
require 'date'

# Renders the two changelog templates with fixture entries. The real data has no
# deprecation yet, so this is the only test that runs the sunset code.
class ChangelogTemplatesTest < Minitest::Test
  SOURCE_DIR = File.expand_path('../source', __dir__)

  Entry = Struct.new(:date, :type, :description, :sunset, keyword_init: true)
  Data = Struct.new(:changelog)

  def fixture_data
    Data.new([
               Entry.new(date: Date.new(2026, 11, 2), type: 'deprecated',
                         description: 'Endpoint `GET /api/old` is deprecated.', sunset: Date.new(2027, 3, 31)),
               Entry.new(date: Date.new(2026, 10, 1), type: 'added', description: 'Field `new` added.')
             ])
  end

  def render(template_name)
    template = File.read(File.join(SOURCE_DIR, template_name), encoding: 'utf-8')
    ERB.new(template).result_with_hash(data: fixture_data)
  end

  def test_text_template_shows_the_sunset_date_only_for_the_deprecation
    text = render('changelog.txt.erb')

    assert_equal 1, text.scan('Sunset date: 2027-03-31').length
    assert_equal 1, text.scan('Sunset date:').length
    assert_includes text, '## 2026-11-02 (deprecated)'
    assert_includes text, 'Last updated: 2026-11-02'
  end

  def test_json_template_includes_the_sunset_date_only_for_the_deprecation
    parsed = JSON.parse(render('api-changelog.json.erb'))
    deprecated, added = parsed['entries']

    assert_equal '2027-03-31', deprecated['sunset']
    refute added.key?('sunset'), 'an entry without a sunset date should not have the key'
    assert_equal '2026-11-02', parsed['updated']
  end
end
