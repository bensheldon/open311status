# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: '.ruby-version'

gem 'babosa'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootstrap', '~> 5.3.8'
gem 'draper'
gem 'font_assets'
gem 'font-awesome-rails'
# faraday_middleware 0.14 (via open311) calls JSON.parse with 2 positional args, removed in json 3
gem 'json', '< 3'
gem 'kramdown'
gem 'open311', github: 'bensheldon/open311', branch: 'api_headers'
gem 'parklife'
gem 'parklife-rails'
gem 'puma'
gem 'rails', '~> 8.1.0'
gem 'sass-rails'
gem 'vite_rails'

group :development, :test do
  gem 'rspec-rails'
end

group :development do
  gem 'herb'
  gem 'listen'
  gem 'rubocop'
  gem 'rubocop-capybara'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara'
  gem 'cuprite'
  gem 'rspec_junit_formatter'
  gem 'webmock'
end
