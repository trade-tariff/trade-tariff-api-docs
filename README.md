# GOV.UK Tariff API Documentation

This is a microsite for providing documentation for the GOV.UK Tariff API.

This documentation is built from source files in this repository and an
[OpenAPI](https://github.com/OAI/OpenAPI-Specification) specification
[file](/v1/openapi.yaml) for the Tariff API.

The framework for this documentation
is provided by the [GOV.UK Tech Docs Template][tech-docs-template] and through
the use of a [fork][forked-widdershins] of [widdershins][widdershins] to
convert the [`openapi.yaml`][tariff-openapi] to Markdown.

## Updating content

The `reference.html` page is built using the
[`openapi.yaml`][tariff-openapi] file. To update content of this site,
modify the files under `source` and the `source/v1/openapi.yaml` file

HTML pages are in the [`/source`][source-dir] of this repository and are
authored using Markdown. You can make edits to these pages by making changes
in a branch or fork of this project and then opening a pull request.

## Running documentation locally

### Installing dependencies

Setting up the documentation requires Ruby and Node. Run the following to
install the necessary dependencies:

```
make requirements
```

### Preview changes

Whilst writing documentation we can run a middleman server to preview how the
published version will look in the browser. After saving a change the preview in
the browser will automatically refresh on HTML pages. However for changes to
[`openapi.yaml`][tariff-openapi] you will need to restart the preview.

Type the following to start the server:

```
make server API_SPEC=source/v1/openapi.yaml
```

You should now be able to view a live preview at http://localhost:4567.

## Publishing changes

Make changes in a branch and make a PR.

## License

[MIT License](LICENSE)

[forked-widdershins]: https://github.com/alphagov/widdershins
[widdershins]: https://github.com/Mermade/widdershins
[tariff-openapi]: https://gitlab.bitzesty.com/clients/trade-tariff/trade-tariff-api-docs/tree/master/source/v1/openapi.yaml
[source-dir]: https://gitlab.bitzesty.com/clients/trade-tariff/trade-tariff-api-docs/tree/master/source
[tech-docs-template]: https://github.com/alphagov/tech-docs-template
