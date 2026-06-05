# llms.txt Design

**Date:** 2026-06-05
**Repo:** trade-tariff-api-docs

## Problem

LLMs have no machine-readable summary of the Trade Tariff API at a well-known location. The `llms.txt` convention (llmstxt.org) provides a standard for this.

## Goal

Add `/llms.txt` and `/llms-full.txt` to the published api-docs site so that both external developers using LLMs and internal tooling can get accurate, up-to-date context about the Trade Tariff API.

## Scope

Core v2 tariff API only — commodities, sections, headings, duties, quotas. Excludes FPO categorisation, green lanes, and reference-data endpoints.

## Approach

ERB templates in `source/`, following existing Middleman conventions. `llms-full.txt.erb` loads the OpenAPI YAML directly and renders it as flat prose at build time. This keeps the full file in sync with the spec automatically on every site build.

## Files

### `source/llms.txt` (static)

Plain markdown following the llmstxt.org spec:

```
# GOV.UK Trade Tariff API

> The GOV.UK Trade Tariff API provides structured access to UK Trade Tariff data including
> commodity codes, duty rates, VAT rates, and trade measures.
> Base URL: https://www.trade-tariff.service.gov.uk/api/v2
> All responses are JSON. No authentication required for public endpoints.
> The API also supports an XI (Northern Ireland) variant at https://www.trade-tariff.service.gov.uk/xi/api/v2

## Notes

- All endpoints return JSON
- No authentication required for public read endpoints
- Date-scoped endpoints accept an `as_of` query parameter (YYYY-MM-DD)
- The XI service returns data for Northern Ireland under the Windsor Framework

## Docs

- [Getting started](https://api.trade-tariff.service.gov.uk/getting-started.html)
- [API reference](https://api.trade-tariff.service.gov.uk/reference.html)
- [OpenAPI spec](https://api.trade-tariff.service.gov.uk/v2/openapi.yaml)
- [Full LLM context](https://api.trade-tariff.service.gov.uk/llms-full.txt)
```

### `source/llms-full.txt.erb` (generated from OpenAPI spec)

ERB template that:

1. Loads `source/v2/openapi.yaml` via `YAML.load_file`
2. Renders a preamble from `spec['info']` and `spec['servers']`
3. Iterates `spec['paths']`, for each endpoint renders:
   - HTTP method + path as a heading
   - `summary` and `description` as prose
   - Parameters (name, location, required, type, description)
   - Response codes with descriptions
   - curl example from `x-code-samples` if present
4. No `$ref` schema expansion — endpoint-level content is sufficient

Output is flat plain text with no front matter or HTML.

## Build behaviour

Middleman treats both files as static assets and copies them to the build root:
- `/llms.txt`
- `/llms-full.txt`

No changes to `config.rb` or the Makefile are required.

## Out of scope

- FPO categorisation endpoints
- Green lanes endpoints
- Reference data endpoints
- Schema/component inlining (`$ref` resolution)
