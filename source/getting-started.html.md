---
title: Getting started
---

# Getting started

## How to use the GOV.UK Trade Tariff APIs

You can use curl for interfacing with the API, however you can also use HTTPie or Postman. To structure fetched responses, you can use jq.

## Accessing content

The GOV.UK Trade Tariff APIs are used to access content from the [UK Trade Tariff Service](https://www.gov.uk/trade-tariff).

Using the Commodities API for example, if you want to access the commodity object for pure-bred breeding animals with the commodity code 0101210000. This can be viewed through this API by making a request to:

```shell
curl https://www.trade-tariff.service.gov.uk/uk/api/commodities/0101210000 \
  -H "Accept: application/vnd.hmrc.2.0+json" | \
  jq
```

Notice that you **need to specify the `Accept`** header with the value `application/vnd.hmrc.2.0+json` to get the response in the correct format.

The commodity object includes all the relevant information about the commodity including:

- Import and export measures
- Information on preferential and non-preferential rules of origin
- Relevant notes

This API can be used in a similar way to access a wide range of information from the UK Trade Tariff Service including:

- Sections
- Chapters
- Quotas
- Geographical areas
- Preferential rules of origin

Find out more about what information can be returned through the [Trade Tariff API](https://api.trade-tariff.service.gov.uk/reference.html).

## Northern Ireland

For trade with Northern Ireland, you might need to apply measures from the EU Tariff and combine these with measures from the UK Tariff.

To do this you will need to access the XI tariff. For example, for pure-bred breeding animals, commodity code 0101210000 is accessed by:

```shell
curl https://www.trade-tariff.service.gov.uk/xi/uk/api/commodities/0101210000 \
  -H "Accept: application/vnd.hmrc.2.0+json" | \
  jq
```

Be aware, the XI tariff API does not contain information about EU quotas. If VAT and/or excise measures are required, these are listed in the UK Tariff.

Find out more about trading and moving goods in and out of [Northern Ireland](https://www.gov.uk/guidance/trading-and-moving-goods-in-and-out-of-northern-ireland).

## Fast Parcel Operators

With time-dependant deliveries between Great Britain and Northern Ireland, you can access the Fast Parcel Operator (FPO) Commodity Code Identification Tool API by making a request to:

```shell
curl -X POST https://search.trade-tariff.service.gov.uk/fpo-code-search \
  -H 'Content-Type: application/json' \
  -H 'X-Api-Key: 140d584511bb37446785ebaa2524f5f900284b5255a3132c' \
  -d '{"description":"green eggs and ham", "digits": 8, "limit": 5}' | \
  jq
```

As a Fast Parcel Operator, you'll need to [contact](mailto:hmrc-trade-tariff-support-g@digital.hmrc.gov.uk) our team to get an API key to use this API.


## Ruby with Rails example

It is simple to make use of the UK Trade Tariff API in your application. This example uses [Ruby](https://www.ruby-lang.org/en/) with the built in `net/http` library to access the Commodities API. It also uses the [Rails cache](https://guides.rubyonrails.org/caching_with_rails.html) to minimise the number of API calls.

```ruby
require 'net/http'
require 'json'
require 'uri'

commodity = Rails.cache.fetch('commodity_0101210000', expires_in: 24.hours) do
  uri = URI.parse('https://www.trade-tariff.service.gov.uk/uk/api/commodities/0101210000')
  response = Net::HTTP.get(uri, { 'Accept' => 'application/vnd.hmrc.2.0+json' })
  JSON.parse(response)
end
attributes = commodity['data']['attributes']

puts "Commodity Code: #{attributes['goods_nomenclature_item_id']}"
puts "Description: #{attributes['formatted_description']}"
puts "Basic Duty Rate: #{attributes['basic_duty_rate']}"
puts "Declarable: #{attributes['declarable']}"
```

This example uses the Ruby on Rails cache, which minimises the number of API calls. It is recommended you cache requests for 24 hours.

It fetches the commodity data for pure-bred breeding animals with the commodity code `0101210000`. The response is parsed from JSON and relevant attributes are printed to the console.

## Node.js example

You can also use the UK Trade Tariff API in a [Node.js](https://nodejs.org) application. Below is an example using the built-in `https` module to access the Commodities API.


```javascript
const https = require('https');
const cache = new Map();
const commodityCode = '0101210000';
const cacheKey = `commodity_${commodityCode}`;
const cacheDuration = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

const cached = cache.get(cacheKey);
if (cached && Date.now() - cached.timestamp < cacheDuration) {
  const attributes = cached.data.data.attributes;
  console.log(`Commodity Code: ${attributes.goods_nomenclature_item_id}`);
  console.log(`Description: ${attributes.formatted_description}`);
  console.log(`Basic Duty Rate: ${attributes.basic_duty_rate}`);
  console.log(`Declarable: ${attributes.declarable}`);
} else {
  https.get(`https://www.trade-tariff.service.gov.uk/uk/api/commodities/${commodityCode}`, {
    headers: {
      'Accept': 'application/vnd.hmrc.2.0+json'
    }
  }, (res) => {
    let data = '';

    res.on('data', (chunk) => {
      data += chunk;
    });

    res.on('end', () => {
      const commodity = JSON.parse(data);
      cache.set(cacheKey, { data: commodity, timestamp: Date.now() });

      const attributes = commodity.data.attributes;
      console.log(`Commodity Code: ${attributes.goods_nomenclature_item_id}`);
      console.log(`Description: ${attributes.formatted_description}`);
      console.log(`Basic Duty Rate: ${attributes.basic_duty_rate}`);
      console.log(`Declarable: ${attributes.declarable}`);
    });
  }).on('error', (err) => {
    console.error(err);
  });
}
```

## Python example

Finally, you can use the UK Trade Tariff API in a [Python](https://www.python.org/) application. Below is an example using the built-in `urllib` library to access the Commodities API.

```python
import urllib.request
import json
import time

cache = {}
commodity_code = '0101210000'
cache_key = f'commodity_{commodity_code}'
cache_duration = 24 * 60 * 60  # 24 hours in seconds

cached = cache.get(cache_key)
if cached and time.time() - cached['timestamp'] < cache_duration:
    commodity = cached['data']
else:
    url = f'https://www.trade-tariff.service.gov.uk/uk/api/commodities/{commodity_code}'
    req = urllib.request.Request(url, headers={'Accept': 'application/vnd.hmrc.2.0+json'})
    with urllib.request.urlopen(req) as response:
        data = response.read().decode('utf-8')
        commodity = json.loads(data)
    cache[cache_key] = {'data': commodity, 'timestamp': time.time()}

attributes = commodity['data']['attributes']
print(f"Commodity Code: {attributes['goods_nomenclature_item_id']}")
print(f"Description: {attributes['formatted_description']}")
print(f"Basic Duty Rate: {attributes['basic_duty_rate']}")
print(f"Declarable: {attributes['declarable']}")
```
