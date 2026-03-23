require "minitest/autorun"

class RateLimitingBannerTest < Minitest::Test
  BUILD_DIR = File.expand_path("../build", __dir__)
  BANNER_HEADING = "From September 2026, rate limiting will apply to the Commodities API to protect service reliability."
  BANNER_BODY = "No action needed today. More guidance to follow"
  EXCLUDED_PAGES = %w[404.html].freeze
  PAGES = %w[index.html reference.html the-commodities-api.html].freeze

  def setup
    self.class.build_site_once
  end

  def test_banner_is_rendered_on_key_docs_pages
    PAGES.each do |page|
      html = File.read(File.join(BUILD_DIR, page))

      assert_includes html, BANNER_HEADING, "#{page} should include the banner heading"
      assert_includes html, BANNER_BODY, "#{page} should include the banner body"
    end
  end

  def test_banner_is_not_rendered_on_excluded_pages
    EXCLUDED_PAGES.each do |page|
      html = File.read(File.join(BUILD_DIR, page))

      refute_includes html, BANNER_HEADING, "#{page} should not include the banner heading"
      refute_includes html, BANNER_BODY, "#{page} should not include the banner body"
    end
  end

  def self.build_site_once
    return if @build_complete

    system("bundle exec rake build", exception: true)
    @build_complete = true
  end
end
