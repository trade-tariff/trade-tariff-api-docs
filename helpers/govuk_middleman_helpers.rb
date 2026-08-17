module GovukMiddlemanHelpers
  def govuk_link_to(text, url)
    link_to(
      text.to_s,
      url,
      class: "govuk-link",
      rel: "noreferrer noopener",
    )
  end

  def govuk_link_to_new_tab(text, url)
    link_to(
      "#{text} (opens in new tab)",
      url,
      class: "govuk-link",
      target: "_blank",
    )
  end

  def govuk_warning_text(fallback_text = "Warning", text = nil, &block)
    if block_given?
      # the first arg is the screenreader fallback
      inner_html = capture_html(&block)
    elsif text.nil?
      # if the user only supplies one arg
      # make that the warning text
      inner_html = fallback_text.to_s
    else
      inner_html = text.to_s
      fallback_text.to_s
    end

    inner_html = ActiveSupport::SafeBuffer.new.safe_concat(inner_html)

    icon = content_tag(:span, "!", class: "govuk-warning-text__icon", "aria-hidden" => "true")
    hidden_span = content_tag(:span, fallback_text, class: "govuk-visually-hidden")
    strong = content_tag(:strong, hidden_span + inner_html, class: "govuk-warning-text__text")
    output = content_tag(:div, icon + strong, class: "govuk-warning-text")

    block_is_template?(block) ? concat_content(output) : output
  end

  def govuk_notification_banner
  end
end
