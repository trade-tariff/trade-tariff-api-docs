requirements:
	npm install
	bundle install

clean:
	rm -rf build

api:
	./generate.js source/v1/openapi.yaml source/reference-v1.html.md.erb
	./generate.js source/v2/openapi.yaml source/reference.html.md.erb

html: requirements clean api
	bundle exec rake build

server: html
	bundle exec middleman server

all: html

