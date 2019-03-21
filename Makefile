requirements:
	npm install
	bundle install

clean:
	rm -rf build

api:
	$(if ${API_SPEC},,$(error Must specify path to the OpenAPI spec file in API_SPEC))
	./generate.js ${API_SPEC} source/reference.html.md.erb

html: requirements clean api
	bundle exec rake build

server: html
	bundle exec middleman server

all: html

