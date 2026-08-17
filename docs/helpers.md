# Govuk Middleman Helpers

Included with this repo are some custom Middleman helper methods.

## GOV.UK Styled link

The `govuk_link_to` helper applies some defaults to the Middleman `link_to`
helper; it adds the class `govuk-link`, and sets the `rel` attribute to
`noreferrer noopener`.

```erb
<%= govuk_link_to "GOV.UK", "https://www.gov.uk" %>
```

Will generate the following HTML:

```erb
<a href="https://www.gov.uk/" class="govuk-link" rel="noreferrer noopener">GOV.UK</a>
```

### New tab

The `govuk_link_to_new_tab` helper extends the `govuk_link_to` helper,
automatically appends "(open in new tab)" to your link text, and sets the
`target` attribute to `_blank`.

```erb
<%= govuk_link_to_new_tab "Register for the service", "https://www.example.com/login" %>
```

Will generate the following HTML:

```html
<a href="https://www.example.com/login" class="govuk-link" target="_blank" rel="noreferrer noopener">Register for the service (opens in new tab)</a>
```

## Warning text

A port of the GOV.UK Design System [Warning text component][0].

[0]: https://design-system.service.gov.uk/components/warning-text/

You can use this helper inline for short warnings, for example:

```erb
<%= govuk_warning_text "You must be licensed to keep a unicorn as a pet." %>
```

This will generate the following HTML:

```html
<div class="govuk-warning-text">
  <span class="govuk-warning-text__icon" aria-hidden="true">!</span>
  <strong class="govuk-warning-text__text">
    <span class="govuk-visually-hidden">Warning</span>
    You must be licensed to keep a unicorn as a pet.
  </strong>
</div>
```

To override the icon fallback text (the `<span>` with class
`govuk-visually-hidden`), supply an additional argument:

```erb
<%= govuk_warning_text "You can no longer apply for a license.", "Information" %>
```

It can also take a block, which allows more complex content:

```erb
<% govuk_warning_text do %>
  You can apply for a license <%= link_to "here (opens in new tab)", "https://www.example.com/" %>.
<% end %>
```

The block form can also override the icon fallback text, by using an argument:

```erb
<% govuk_warning_text "Information" do %>
  You must renew your license yearly.
<% end%>
```
