# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'rate_limiting_banner_test'

class AnalyticsTest < Minitest::Test
  BUILD_DIR = File.expand_path('../build', __dir__)
  GTM_CONTAINER_ID = 'GTM-KPM7NRDG'
  PAGES = %w[index.html reference.html categorisation-sample-client.html].freeze

  def setup
    RateLimitingBannerTest.build_site_once
  end

  def test_pages_include_gtm_snippet_and_cookie_banner
    PAGES.each do |page|
      html = File.read(File.join(BUILD_DIR, page))

      assert_includes html, 'googletagmanager.com/gtm.js', "#{page} should include GTM bootstrap"
      assert_includes html, GTM_CONTAINER_ID, "#{page} should include GTM container id"
      assert_includes html, 'govuk-cookie-banner', "#{page} should include cookie banner"
      assert_includes html, 'Accept analytics cookies', "#{page} should include accept cookies button"
    end
  end

  def test_pages_do_not_include_legacy_universal_analytics
    PAGES.each do |page|
      html = File.read(File.join(BUILD_DIR, page))

      refute_includes html, 'google-analytics.com/analytics.js', "#{page} should not include legacy UA"
      refute_includes html, 'UA-97208357-3', "#{page} should not include legacy UA tracking id"
    end
  end
end
