.PHONY: clean html requirements serve test update-tech-docs

default: html

serve: html
	bundle exec middleman server

html: requirements clean
	bundle exec middleman build --clean

requirements:
	bundle install
	which dot || (echo "Please install Graphviz via your system package manager" && exit 1)

clean:
	rm -rf build

test:
	bundle exec rake test

update-tech-docs:
	bundle update govuk_tech_docs && FIRST_TIME=false bundle exec middleman init . -T alphagov/tech-docs-template
