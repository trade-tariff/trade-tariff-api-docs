require 'minitest/autorun'

class RateLimitingBannerTest < Minitest::Test
  BUILD_DIR = File.expand_path('../build', __dir__)
  BANNER_HEADING = 'From September 2026, rate limiting will apply to the Trade Tariff API to protect service reliability.'
  BANNER_BODY = 'Access a higher rate limit through the Trade Tariff Developer Portal.'
  BANNER_LINK_TEXT = 'Find out more about the Developer Portal'
  EXCLUDED_PAGES = %w[404.html].freeze
  PAGES = %w[index.html reference.html the-trade-tariff-api.html].freeze

  def setup
    self.class.build_site_once
  end

  def test_banner_is_rendered_on_key_docs_pages
    PAGES.each do |page|
      html = File.read(File.join(BUILD_DIR, page))

      assert_includes html, BANNER_HEADING, "#{page} should include the banner heading"
      assert_includes html, BANNER_BODY, "#{page} should include the banner body"
      assert_includes html, BANNER_LINK_TEXT, "#{page} should include the Developer Portal link text"
    end
  end

  def test_banner_is_not_rendered_on_excluded_pages
    EXCLUDED_PAGES.each do |page|
      html = File.read(File.join(BUILD_DIR, page))

      refute_includes html, BANNER_HEADING, "#{page} should not include the banner heading"
      refute_includes html, BANNER_BODY, "#{page} should not include the banner body"
      refute_includes html, BANNER_LINK_TEXT, "#{page} should not include the Developer Portal link text"
    end
  end

  def self.build_site_once
    return if @build_complete

    system('make html', exception: true)
    @build_complete = true
  end
end
