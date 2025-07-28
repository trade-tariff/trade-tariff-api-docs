serve: html
	bundle exec middleman server

html: requirements clean
	bundle exec rake build

requirements:
	npm install
	bundle install
	which dot || (echo "Please install Graphviz via your system package manager" && exit 1)

clean:
	rm -rf build

all: html

validate:
	bin/swagger_validate

update-tech-docs:
	bundle update govuk_tech_docs && FIRST_TIME=false bundle exec middleman init . -T alphagov/tech-docs-template
