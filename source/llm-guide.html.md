---
title: LLM Integration Guide - Trade Tariff API
---

# Trade Tariff API: LLM Integration Guide

This guide is written for developers (and LLMs) who need to integrate with the GOV.UK Trade Tariff API. It is a single flat page designed to be read top-to-bottom. It covers authentication, the most common query patterns, error handling, rate limiting, and the key domain gotchas that trip up new integrations.

---

## What the API does

The Trade Tariff API provides programmatic access to the UK Trade Tariff — the official schedule of commodity codes, duty rates, import/export controls, and trade measures that govern goods crossing UK borders.

**Who uses it:** customs brokers, logistics software, e-commerce platforms, compliance tools, and government services that need to classify goods and look up applicable duties or restrictions.

**Base URLs:**

| Service | Base URL |
|---------|----------|
| UK tariff | `https://api.trade-tariff.service.gov.uk/uk/api/v2` |
| XI (Northern Ireland) tariff | `https://api.trade-tariff.service.gov.uk/xi/api/v2` |

All responses are JSON:API (`application/vnd.hmrc.2.0+json`). Send the `Accept` header on every request.

---

## Authentication

The API is publicly available — no authentication is required for read endpoints. A simple request looks like:

```shell
curl -s \
  -H "Accept: application/vnd.hmrc.2.0+json" \
  "https://api.trade-tariff.service.gov.uk/uk/api/v2/commodities/0101210000"
```

**Higher rate limits with managed credentials:** From September 2026, unauthenticated requests will be subject to a lower rate limit. Register on the [Trade Tariff developer portal](https://hub.trade-tariff.service.gov.uk/) to obtain a bearer token and access a higher limit.

### Authenticating with a bearer token (optional, for higher rate limits)

Register at the [Trade Tariff developer portal](https://hub.trade-tariff.service.gov.uk/) to receive a bearer token. Send it in the `Authorization` header on every request:

```shell
curl -s \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/vnd.hmrc.2.0+json" \
  "https://api.trade-tariff.service.gov.uk/uk/api/v2/commodities/0101210000"
```

---

## Common query patterns

### Pattern 1: Look up a commodity code

Retrieve the full trade data for a 10-digit commodity code. This is the most common query — it returns the commodity's measures (duties, restrictions, licences), measure conditions, rules of origin, and footnotes.

```shell
GET /uk/api/v2/commodities/{commodity_code}
```

Example — pure-bred breeding animals:

```shell
curl -s \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Accept: application/vnd.hmrc.2.0+json" \
  "https://api.trade-tariff.service.gov.uk/uk/api/v2/commodities/0101210000"
```

Key fields in the response:

```json
{
  "data": {
    "id": "0101210000",
    "type": "commodity",
    "attributes": {
      "goods_nomenclature_item_id": "0101210000",
      "description": "Pure-bred breeding animals",
      "declarable": true,
      "producline_suffix": "80"
    },
    "relationships": {
      "import_measures": { "data": [...] },
      "export_measures": { "data": [...] }
    }
  },
  "included": [
    ...
  ]
}
```

The `included` array contains all related entities (measures, measure types, measure conditions, duty expressions, geographical areas, etc.) referenced by the `data` object. Parse the whole `included` array and resolve relationships by `id` and `type` — entities appear only once.

### Pattern 2: Search for commodity codes by description

Use the search endpoint to find commodity codes matching a keyword:

```shell
GET /uk/api/v2/search?q={search_term}
```

Example:

```shell
curl -s \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Accept: application/vnd.hmrc.2.0+json" \
  "https://api.trade-tariff.service.gov.uk/uk/api/v2/search?q=horses"
```

The response returns a list of matching commodities with their descriptions and codes. Use this to let users find the right commodity code before fetching full detail.

### Pattern 3: Browse sections and chapters

The tariff is organised as a hierarchy: **sections → chapters → headings → subheadings → commodities**. Use these endpoints to navigate the structure.

List all sections:

```shell
GET /uk/api/v2/sections
```

Get a chapter (two-digit HS code):

```shell
GET /uk/api/v2/chapters/01
```

Get a heading (four-digit code):

```shell
GET /uk/api/v2/headings/0101
```

Each response includes child nodes and their descriptions, allowing you to build a navigation tree.

### Pattern 4: Look up a heading or subheading

Headings and subheadings are structural nodes that may not themselves be declarable. Use the headings endpoint when you have a 4-digit or 6-digit code:

```shell
GET /uk/api/v2/headings/0101
```

The response lists the subheadings under the heading, each with a `declarable` flag. Only codes with `"declarable": true` (i.e. `producline_suffix` of `"80"` and no children) can be used on a customs declaration.

---

## Error codes

| HTTP status | Meaning | What to do |
|-------------|---------|------------|
| `400 Bad Request` | Malformed request — invalid commodity code format, bad query parameter | Fix the request. Commodity codes must be 10 digits. |
| `401 Unauthorized` | Expired or invalid OAuth token (only relevant when using managed credentials) | Request a new token and retry once. |
| `403 Forbidden` | Valid token but insufficient permissions | Check your developer portal credentials. |
| `404 Not Found` | Commodity code or resource does not exist in the tariff | The code may be non-declarable, use a heading/subheading endpoint instead, or the code may not exist. |
| `422 Unprocessable Entity` | Request understood but semantically invalid | Check the response body for a descriptive error message. |
| `429 Too Many Requests` | Rate limit exceeded | See the rate limiting section below. |
| `500 Internal Server Error` | Server error | Retry with exponential backoff. If persistent, check the [service status page](https://status.trade-tariff.service.gov.uk/). |

---

## Rate limiting

**From September 2026**, rate limiting will apply to protect service reliability. Requests that exceed the limit receive a `429 Too Many Requests` response.

The `Retry-After` header in the 429 response tells you how many seconds to wait before retrying:

```
HTTP/1.1 429 Too Many Requests
Retry-After: 10
```

**Handling 429s:**

1. Read the `Retry-After` value.
2. Wait that many seconds.
3. Retry the request.
4. If you receive repeated 429s, apply exponential backoff with jitter.

To access a higher rate limit, register through the [Trade Tariff developer portal](https://hub.trade-tariff.service.gov.uk/).

---

## Known gotchas

### UK vs XI (Northern Ireland) tariff

The UK and XI tariffs are separate datasets. The XI tariff reflects Northern Ireland's continued alignment with EU rules under the Windsor Framework.

Key differences:

- **Quotas**: The XI tariff does not contain EU quota information. Use the UK tariff for quota lookups.
- **VAT and excise**: If you need VAT or excise measures for goods moving to/from Northern Ireland, these are listed in the UK tariff, not the XI tariff.
- **Meursing codes**: The `reduction_indicator`, `meursing`, and `resolved_duty_expression` fields are only populated on the XI tariff for goods subject to Meursing calculation (agricultural processed products).
- **Legal acts**: On the UK tariff a measure references one legal act. On the XI tariff, a measure may reference more than one legal act if the base regulation has been modified.
- **Monetary units**: On the UK tariff, specific duty amounts use `GBP`. On the XI tariff, they use `EUR`.
- **Paths**: Replace `uk/` with `xi/` in the URL path. For example: `https://api.trade-tariff.service.gov.uk/xi/api/v2/commodities/0101210000`.

### Declarable vs non-declarable commodities

Only declarable commodities can appear on a customs declaration. A commodity is declarable when:

- Its `producline_suffix` is `"80"`, **and**
- It has no descendant commodity codes (it is a leaf node in the hierarchy).

The `declarable` field in the commodity attributes will be `true` for these codes. If you query a heading or subheading with `/commodities/{code}` and receive a 404, the code is probably a heading — use `/headings/{code}` or `/subheadings/{code}` instead.

### The `included` section and JSON:API

The API follows the [JSON:API](https://jsonapi.org/) specification. Related entities (measures, duty expressions, geographical areas, measure conditions, etc.) are embedded in the top-level `included` array. Each entity appears **only once**, regardless of how many times it is referenced.

To work with measure conditions, duty expressions, or geographical areas:

1. Parse the entire `included` array into a lookup map keyed by `{type}/{id}`.
2. Resolve relationships by looking up `{ "type": "...", "id": "..." }` references in the map.

Do not try to extract individual entities inline — you will miss data when the same entity is referenced from multiple parents.

### Measure condition boolean logic

Import and export measures can have conditions that must be satisfied. The boolean logic is determined by **condition codes**:

- Conditions sharing the **same condition code** are in an **OR** relationship — the trader must satisfy one.
- If a measure has conditions with **more than one condition code**, an **AND** relationship exists between the groups.

For complex measures (veterinary controls, waste controls), use the `measure_condition_permutation_group` and `measure_condition_permutation` entities in the `included` array. These pre-computed permutations enumerate all valid combinations and are the recommended way to display requirements to end users.

### The `as_of` date parameter

Many endpoints accept an `as_of` query parameter (format: `YYYY-MM-DD`) to retrieve tariff data as it stood on a given date. This is useful for:

- Checking what duties applied at the time of a historical shipment.
- Verifying future duty rates when a change has been announced.

If omitted, the response reflects today's tariff.

```shell
GET /uk/api/v2/commodities/0101210000?as_of=2024-01-01
```

---

## Further reading

- [Full API documentation](https://api.trade-tariff.service.gov.uk/the-trade-tariff-api.html) — step-by-step guide covering all endpoints in depth
- [API reference](https://api.trade-tariff.service.gov.uk/reference.html) — interactive reference with request/response schemas
- [OpenAPI specification](https://api.trade-tariff.service.gov.uk/openapi.yaml) — machine-readable OAS 3.1 spec
- [Full LLM context](https://api.trade-tariff.service.gov.uk/llms-full.txt) — prose rendering of all v2 endpoints
- [Developer portal](https://hub.trade-tariff.service.gov.uk/) — register for API credentials
