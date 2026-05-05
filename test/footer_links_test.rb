# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'rate_limiting_banner_test'

class FooterLinksTest < Minitest::Test
  BUILD_DIR = File.expand_path('../build', __dir__)

  def setup
    RateLimitingBannerTest.build_site_once
  end

  def test_footer_includes_agreed_meta_links
    html = File.read(File.join(BUILD_DIR, 'index.html'))

    assert_includes html, 'govuk-footer__inline-list', 'footer should include meta link list'
    assert_includes html, 'href="https://hub.trade-tariff.service.gov.uk/"', 'Developer portal should link to hub'
    assert_includes html, 'https://www.trade-tariff.service.gov.uk/enquiry_form', 'Enquiry form link'
    assert_includes html, 'https://www.trade-tariff.service.gov.uk/feedback', 'Feedback link'
    assert_includes html, 'https://hub.trade-tariff.service.gov.uk/privacy', 'Privacy policy link'
    assert_includes html, 'https://hub.trade-tariff.service.gov.uk/cookies', 'Cookies link'
    assert_includes html, 'https://www.trade-tariff.service.gov.uk/terms', 'Terms and conditions link'
  end
end
