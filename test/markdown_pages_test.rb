require 'minitest/autorun'
require_relative 'rate_limiting_banner_test'

class MarkdownPagesTest < Minitest::Test
  BUILD_DIR = File.expand_path('../build', __dir__)

  EXPECTED_PAGES = %w[
    the-trade-tariff-api.md
    reference-data.md
    categorisation.md
    developer-portal.md
    fpo/terms-and-conditions.md
  ].freeze

  def setup
    RateLimitingBannerTest.build_site_once
  end

  def test_markdown_files_are_generated
    EXPECTED_PAGES.each do |page|
      assert File.exist?(File.join(BUILD_DIR, page)), "expected #{page} to exist in build"
    end
  end

  def test_markdown_files_contain_no_frontmatter
    EXPECTED_PAGES.each do |page|
      content = File.read(File.join(BUILD_DIR, page), encoding: 'utf-8')
      refute_match(/\A---\n/, content, "#{page} should not start with YAML frontmatter")
    end
  end

  def test_markdown_files_contain_no_erb_tags
    EXPECTED_PAGES.each do |page|
      content = File.read(File.join(BUILD_DIR, page), encoding: 'utf-8')
      refute_match(/<%/, content, "#{page} should not contain ERB tags")
    end
  end

  def test_markdown_files_contain_content
    EXPECTED_PAGES.each do |page|
      content = File.read(File.join(BUILD_DIR, page), encoding: 'utf-8')
      assert content.length > 100, "#{page} should contain substantial content"
    end
  end
end
