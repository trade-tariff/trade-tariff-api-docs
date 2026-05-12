OPENAPI_SOURCE_URL ?= https://raw.githubusercontent.com/trade-tariff/trade-tariff-backend/main/swagger/v2/swagger.json
OPENAPI_PATH ?= tmp/backend-openapi/swagger.json

.PHONY: serve html requirements openapi-reference clean all test update-tech-docs

serve: html
	bundle exec middleman server

html: requirements openapi-reference clean
	bundle exec rake build

requirements:
	bundle install
	which dot || (echo "Please install Graphviz via your system package manager" && exit 1)

openapi-reference:
	BACKEND_OPENAPI_URL="$(OPENAPI_SOURCE_URL)" BACKEND_OPENAPI_PATH="$(OPENAPI_PATH)" bin/fetch-backend-openapi

clean:
	rm -rf build

all: html

test:
	bundle exec ruby -I test test/openapi_reference_renderer_test.rb
	bundle exec ruby -I test test/fetch_backend_openapi_test.rb
	bundle exec ruby -I test test/rate_limiting_banner_test.rb
	bundle exec ruby -I test test/footer_links_test.rb

update-tech-docs:
	bundle update govuk_tech_docs && FIRST_TIME=false bundle exec middleman init . -T alphagov/tech-docs-template
