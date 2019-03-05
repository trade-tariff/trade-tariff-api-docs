---
title: Getting Started
---

# Getting Started

This guide introduces a number of key concepts in GOV.UK Tariff API through
the usage of examples. It utilises [curl](https://curl.haxx.se/) for
interfacing with the API on the command line and is chosen due to the wide
availability of curl, however you may prefer the structured output of
using [HTTPie](https://httpie.org/) or piping the curl responses
through [jq](https://stedolan.github.io/jq/).

## Accessing Content

GOV.UK Tariff API is used to access content that is hosted on
[www.gov.uk/trade-tariff](https://www.gov.uk/trade-tariff) (referred to as GOV.UK Tariff).
For a given commodity, for example [Pure-bred breeding animals](https://www.trade-tariff.service.gov.uk/trade-tariff/commodities/0101210000), we can look this up through this API:

```shell
curl https://trade-tariff.service.gov.uk/v1/commodities/0101210000.json
```

This will return a [`commodity`][commodity] object. Within this object are
fields that describe the commodity itself, it import and export measures, footnotes, 
metadata and associations and other content.

### Harmonized System

The [Harmonized Commodity Description and Coding System][harmonized-system], also known as the Harmonized System (HS) of tariff nomenclature is an internationally standardized system of names and numbers to classify traded products.

The HS is organized logically by economic activity or component material. The HS is organized into 21 sections, which are subdivided into 97 chapters. The 97 HS chapters are further subdivided into approximately 5,000 headings and subheadings.

Many of the objects returned from this API include a `goods_nomenclature_item_id` field, which is an implementation of the [Combined Nomenclature][combined-nomenclature], a system of classifying goods under the HS.

```
{
  ...
  "goods_nomenclature_item_id": "0101210000",
  ...
}
```

Every [`commodity`][commodity] (e.g., heading and sub-heading) has a `goods_nomenclature_item_id` and this value is used to identify any commodity in the Tariff.

<!-- The "base" aspect of this field is used as it indicates the root path of this
piece of content as some pieces of content
[span multiple pages][multiple-pages]. -->

### Measures

```
{
  ...
  "import_measures": [ 
    {
      "id": 3563221,
      ...
    }
  ],
  "export_measures": [
    {
      "id": 3563221,
      ...
    }
   ],
  ...
}
```

The `import_measures` and `import_measures` fields contain information about measures that affect importing and exporting goods. These fields are arrays, containing a number of `measure` objects, and each of these objects is a single import or export measure that applies to a commodity.

## Making use of content

It can be simple to make use of GOV.UK in your application. The example below
illustrates a example utilising [Ruby on Rails](http://rubyonrails.org/)
with [Rest Client](https://github.com/rest-client/rest-client).


```ruby
require "rest-client"

commodity = Rails.cache.fetch("/v1/commodities/0101210000.json", expires_in: 1.day) do
  response = RestClient.get("https://trade-tariff.service.gov.uk/v1/commodities/0101210000.json", { content_type: "json" })
  JSON.parse(response.body).dig("details", "body")
end

content = "<h1>GOV.UK Tariff Information</h1><div>#{commodity}</div>"
```

In this example we utilise the Rails cache layer so that we can infrequently
access the content on the API.

We then use the API to access the content for [Pure-bred breeding animals](https://www.trade-tariff.service.gov.uk/trade-tariff/commodities/0101210000). In the response we access the `body` field from within the `details` object. We store this to a variable `commodity`.

Finally we embed this in our own Ruby on Rails app and are ready to output to users.

[commodity]: /reference.html#commodity
[harmonized-system]: http://www.wcoomd.org/en/topics/nomenclature/overview/what-is-the-harmonized-system.aspx
[combined-nomenclature]: https://ec.europa.eu/taxation_customs/business/calculation-customs-duties/what-is-common-customs-tariff/combined-nomenclature_en
