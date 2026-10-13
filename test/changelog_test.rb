# frozen_string_literal: true

require 'minitest/autorun'
require 'yaml'
require 'json'
require 'date'

# Reads the site that `make html` builds into build/, as CI does before `make test`.
class ChangelogTest < Minitest::Test
  BUILD_DIR = File.expand_path('../build', __dir__)
  DATA_FILE = File.expand_path('../data/changelog.yml', __dir__)
  LLMS_TXT_FILE = File.expand_path('../source/llms.txt', __dir__)
  ALLOWED_TYPES = %w[added breaking deprecated].freeze

  def entries
    YAML.load_file(DATA_FILE, permitted_classes: [Date])
  end

  def test_every_entry_has_date_type_and_description
    entries.each do |entry|
      assert_kind_of Date, entry['date'], "#{entry.inspect} needs a date"
      assert_includes ALLOWED_TYPES, entry['type'], "#{entry.inspect} has an unknown type"
      refute_empty entry['description'].to_s.strip, "#{entry.inspect} needs a description"
    end
  end

  def test_only_deprecations_carry_a_sunset_date
    entries.each do |entry|
      next unless entry.key?('sunset')

      assert_equal 'deprecated', entry['type'], "#{entry.inspect} has a sunset date but is not a deprecation"
      assert_kind_of Date, entry['sunset']
    end
  end

  def test_entries_are_newest_first
    dates = entries.map { |entry| entry['date'] }

    assert_equal dates.sort.reverse, dates
  end

  def test_text_changelog_is_published_and_lists_every_entry
    content = File.read(File.join(BUILD_DIR, 'changelog.txt'), encoding: 'utf-8')

    refute_match(/<%/, content, 'changelog.txt should not contain ERB tags')
    entries.each do |entry|
      assert_includes content, entry['date'].iso8601
      assert_includes content, entry['description'].strip
    end
  end

  def test_json_changelog_is_published_and_matches_the_data
    parsed = JSON.parse(File.read(File.join(BUILD_DIR, 'api-changelog.json'), encoding: 'utf-8'))

    expected_entries = entries.map do |entry|
      expected = {
        'date' => entry['date'].iso8601,
        'type' => entry['type'],
        'description' => entry['description'].strip
      }
      expected['sunset'] = entry['sunset'].iso8601 if entry['sunset']
      expected
    end

    assert_equal expected_entries, parsed['entries']
    assert_equal entries.first['date'].iso8601, parsed['updated']
  end

  def test_llms_txt_links_to_both_changelog_urls
    llms_txt = File.read(LLMS_TXT_FILE, encoding: 'utf-8')

    assert_includes llms_txt, 'https://docs.trade-tariff.service.gov.uk/changelog.txt'
    assert_includes llms_txt, 'https://docs.trade-tariff.service.gov.uk/api-changelog.json'
  end
end
