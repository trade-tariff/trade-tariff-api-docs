---
title: Getting Started
---

# Getting Started

This guide introduces a number of key concepts in GOV.UK Trade Tariff API through the usage of examples. It utilises [curl](https://curl.haxx.se/) for interfacing with the API on the command line and is chosen due to the wide availability of curl, however you may prefer the structured output of using [HTTPie](https://httpie.org/) or piping the curl responses through [jq](https://stedolan.github.io/jq/).

## Accessing Content

The GOV.UK Trade Tariff API is used to access content that is hosted on [www.gov.uk/trade-tariff](https://www.gov.uk/trade-tariff) for a given commodity. For example, [Pure-bred breeding animals](https://www.trade-tariff.service.gov.uk/commodities/0101210000), with a commodity code of 0101210000, can be viewed through this API:

```shell
curl https://www.trade-tariff.service.gov.uk/api/v2/commodities/0101210000
```

This will return a [`commodity`][commodity] object. Within this object are fields that describe the commodity itself, its import and export measures, footnotes, metadata and associations and other content from the UK Tariff.

For trade with Northern Ireland (known as the XI Tariff), you may need to apply measures from the EU Tariff as per terms of the UK's exit from the EU (see [Trading and moving goods in and out of Northern Ireland - GOV.UK](https://www.gov.uk/guidance/trading-and-moving-goods-in-and-out-of-northern-ireland) for more information). EU Measures for Northern Ireland (XI) may need to be combined with Measures from the UK Tariff e.g. VAT and excise measures.

If you would like to view the EU Tariff Measures then access via this API (adding /xi):

```shell
curl https://www.trade-tariff.service.gov.uk/xi/api/v2/commodities/0101210000
```

Note: The /xi API does not contain EU quotas. If VAT and/or excise measures are required, these are listed in the UK Tariff. The /xi Online Trade Tariff website front end follows this principle.

### Harmonized System

The [Harmonized Commodity Description and Coding System][harmonized-system], also known as the Harmonized System (HS) of tariff nomenclature is an internationally standardized system of names and numbers to classify traded products.

The HS is organized logically by economic activity or component material. The HS is organized into 21 sections, which are subdivided into 99 chapters. The 99 chapters are further subdivided into approximately 5,000 headings and subheadings.

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

<!-- ### Measures

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
 -->
## Making use of content

### Ruby on Rails

It can be simple to make use of API in your application. The example below utilises [Ruby on Rails](http://rubyonrails.org/) with [Rest Client](https://github.com/rest-client/rest-client).


```ruby
require "rest-client"

commodity = Rails.cache.fetch("/api/v1/commodities/0101210000", expires_in: 1.day) do
  response = RestClient.get("https://www.trade-tariff.service.gov.uk/api/v1/commodities/0101210000", { content_type: "json" })
  JSON.parse(response.body).dig("details", "body")
end

content = "<h1>GOV.UK Tariff Information</h1><div>#{commodity}</div>"
```

In this example we utilise the Rails cache so that we can infrequently can minimise the number of times we call the API. The Trade Tariff is updated daily so a cache of 1 day is recommended.

We then use the API to access the content for [Pure-bred breeding animals](https://www.trade-tariff.service.gov.uk/commodities/0101210000). In the response we access the `body` field from within the `details` object. We store this to a variable `commodity`.

Finally we embed this in our own Ruby on Rails app and are ready to output to users.

### node.js with Axios

The example below uses [node.js](https://nodejs.org/) and the popular [Axios](https://github.com/axios/axios) module, a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises)-based HTTP client for node.js and the browser. Here, we retrieve a commodity and print its `formatted_description` to the console.

```javascript
const axios = require('axios');

axios.get('https://www.trade-tariff.service.gov.uk/api/v1/commodities/0101210000')
     .then(response => {
       console.log(response.data.formatted_description);
      })
     .catch(error => {
       console.log(error);
     });
```

Note the use of `.then()` to handle the Promise, and errors are handled by `.catch()`. Axios handles converting the JSON response to a javascript object.


[commodity]: /reference.html#commodity
[harmonized-system]: http://www.wcoomd.org/en/topics/nomenclature/overview/what-is-the-harmonized-system.aspx
[combined-nomenclature]: https://ec.europa.eu/taxation_customs/business/calculation-customs-duties/what-is-common-customs-tariff/combined-nomenclature_en
