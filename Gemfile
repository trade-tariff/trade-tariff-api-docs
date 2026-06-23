# frozen_string_literal: true

source 'https://rubygems.org'

ruby File.read('.ruby-version')

gem 'benchmark'
gem 'bigdecimal', '>= 1.4.0'
gem 'brakeman'
gem 'builder'
gem 'cgi'
# source/layouts/_header.erb and _footer.erb override templates from this gem; after upgrading,
# run bin/tech-docs-layout-upstream-hint and reconcile those files with upstream.
gem 'govuk_tech_docs'
gem 'logger'
gem 'middleman-gh-pages'
gem 'mutex_m'
gem 'openapi3_parser'
gem 'ostruct'
gem 'rdoc'
gem 'sprockets', '~> 4.0'

gem 'rubocop-govuk'

group :test do
  gem 'debride', '~> 1.15', require: false
end
