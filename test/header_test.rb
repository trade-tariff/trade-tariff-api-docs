# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'rate_limiting_banner_test'

class HeaderTest < Minitest::Test
  BUILD_DIR = File.expand_path('../build', __dir__)

  def setup
    RateLimitingBannerTest.build_site_once
  end

  def test_header_links_govuk_logo_to_govuk_and_shows_service_name_in_service_navigation
    html = File.read(File.join(BUILD_DIR, 'index.html'))

    assert_includes html, 'href="https://www.gov.uk"', 'GOV.UK logo should link to gov.uk'
    refute_match(/govuk-header__product-name[\s\S]*Trade Tariff API documentation/, html,
                 'service name should not appear in the black GOV.UK header')
    assert_match(/govuk-service-navigation__service-name[\s\S]*Trade Tariff API documentation/, html,
                 'service name should appear in the service navigation bar')
  end
end
