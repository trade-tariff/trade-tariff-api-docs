requirements:
	npm install
	bundle install
	which dot || (echo "Please install Graphviz via your system package manager" && exit 1)

clean:
	rm -rf build

html: requirements clean
	bundle exec rake build

serve: html
	bundle exec middleman server

all: html

validate:
	bin/swagger_validate
