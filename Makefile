 serve: html
	bundle exec middleman server

html: requirements clean
	bundle exec rake build

requirements:
	bundle install
	which dot || (echo "Please install Graphviz via your system package manager" && exit 1)

clean:
	rm -rf build

all: html

test:
	bundle exec ruby -I test test/rate_limiting_banner_test.rb test/footer_links_test.rb test/header_test.rb test/analytics_test.rb

update-tech-docs:
	bundle update govuk_tech_docs && FIRST_TIME=false bundle exec middleman init . -T alphagov/tech-docs-template
