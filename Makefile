requirements:
	npm install
	bundle install
	which dot || (echo "Please install Graphviz via your system package manager" && exit 1)

clean:
	rm -rf build

api:
	./generate.js source/v2/openapi.yaml source/reference.html.md.erb
	./generate.js source/beta/openapi.yaml source/reference-beta.html.md.erb
	./generate.js source/v2/greenlanes-openapi.yaml source/green-lanes.html.md.erb
	./generate.js source/v2/greenlanes-old-openapi.yaml source/green-lanes-old.html.md.erb
	./generate.js source/fpo/fpo-commodity-tool-openapi.yaml source/fpo.html.md.erb

html: requirements clean api
	bundle exec rake build

serve: html
	bundle exec middleman server

all: html

validate:
	bin/swagger_validate

