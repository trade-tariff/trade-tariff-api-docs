# GOV.UK Tariff API Documentation

This is a microsite for providing documentation for the GOV.UK Tariff API.

This documentation is built from source files in this repository using the
[GOV.UK Tech Docs Template][tech-docs-template].

The main Trade Tariff API reference is currently maintained directly in
`source/reference.html.md.erb`. The separate FPO documentation page keeps its
own OpenAPI source in `source/fpo/fpo-commodity-tool-openapi.yaml`.

These docs are deployed to the following URLs:

- *Development* - https://api.dev.trade-tariff.service.gov.uk
- *Staging* - https://api.staging.trade-tariff.service.gov.uk
- *Production* - https://api.trade-tariff.service.gov.uk

## Updating content

To update content on this site, modify the files under the `source` directory.

Most pages are authored in Markdown or ERB under [`/source`][source-dir]. You
can make edits by changing the relevant file in a branch and then opening a pull
request.

The main [`/reference.html`](https://api.trade-tariff.service.gov.uk/#gov-uk-trade-tariff-api)
page is built from `source/reference.html.md.erb`, which is the current
canonical source for that reference content.

The OpenAPI Specification (OAS) defines a standard, language-agnostic interface to RESTful APIs which allows both humans and computers to discover and understand the capabilities of the service without access to source code, documentation, or through network traffic inspection. When properly defined, a consumer can understand and interact with the remote service with a minimal amount of implementation logic.

### Updating the API Documentation

To update the Trade Tariff API documentation, you may follow this general workflow:

- If the changes involve the content of the HTML pages (for example `/index` or
  `/getting-started`), edit the corresponding `.md` or `.md.erb` template
  under `source/*`.

  - edit `source/index.html.md.erb` or `source/getting-started.html.md`
  - open or view [http://localhost:4567](http://localhost:4567) in a browser, the browser should automatically reload the page after changes are saved

- If the changes involve the main API reference page, edit
  `source/reference.html.md.erb`.

  - edit `source/reference.html.md.erb`

  - ```shell
    make serve
    ```

  - manually reload [http://localhost:4567/reference.html](http://localhost:4567/reference.html)
    in a browser when the Middleman server restarts

- If the changes involve the FPO documentation's OpenAPI source, edit
  `source/fpo/fpo-commodity-tool-openapi.yaml` and preview the generated page
  through the local site build.

- It is also useful to add an entry in the `NEWS.yml` file, this information will be published on the Latest News page for users viewing these docs. It will also be added to the `/feed.xml` atom feed for anyone subscribing for updates.

## Running documentation locally

### Pre Requisite

Graphviz installed in your local environment

### Manual Build and Deploy

Manual build and deploy is not necessary if automated deploy is used.

1. Build the documentation

```
bundle exec middleman build --clean
```

2. Push to prod

```
cf push tariff-api-production
```

### Installing dependencies

Setting up the documentation requires Ruby and Node. Run the following to install the necessary dependencies:

```
make requirements
```

**Note:** You will also need to manually install Graphviz via your package manager

### Preview changes

Whilst writing documentation we can run a middleman server to preview how the
published version will look in the browser. After saving a change the preview in
the browser will automatically refresh on HTML pages. Changes to large ERB
templates such as `source/reference.html.md.erb` may require a manual reload or
server restart to pick up structural edits.

Type the following to start the server:

```
make serve
```

### VS Code Dev Container

You can now clone the solution and open the folder in VS Code.
Go to the command menu > Show and Run Commands
Select "Dev-Containers: Open Folder in Container..."
The container will be started and then the application will be built and started.

You should now be able to view a live preview at <http://localhost:4567>.

## Layout overrides (`govuk_tech_docs`)

This site replaces the Tech Docs gem’s `_header.erb` and `_footer.erb` under `source/layouts/` (header/footer behaviour for Trade Tariff). Header links and footer URLs are configured in `config/tech-docs.yml`.

After **`bundle update govuk_tech_docs`**, run **`bin/tech-docs-layout-upstream-hint`** — it prints the upstream GitHub paths for your gem version so you can merge any gem changes into those two files.

## Publishing documentation

### Development

Any changes pushed to GitHub on a branch (eg, a Pull Request) will be deployed
automatically to the [Development URL](https://tariff-api-dev.london.cloudapps.digital)

### Production

Any changes to `main` on GitHub will be deployed automatically to our published docs
at [api.trade-tariff.service.gov.uk](https://api.trade-tariff.service.gov.uk)

## License

[MIT License](LICENSE)

[source-dir]: https://github.com/trade-tariff/trade-tariff-api-docs/tree/main/source
[tech-docs-template]: https://github.com/alphagov/tech-docs-template
