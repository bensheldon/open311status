# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: '.ruby-version'

gem "actioncable-enhanced-postgresql-adapter"
gem 'activerecord-explain-analyze'
gem 'activerecord-has_some_of_many'
gem 'activerecord-postgis-adapter'
gem 'autoprefixer-rails'
gem 'aws-sdk-s3'
gem 'babosa'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootstrap', '~> 5.3.8'
gem 'chart-js-rails'
gem 'chartkick'
gem 'coffee-rails'
gem 'draper'
gem 'factory_bot_rails'
gem 'faker'
gem 'font_assets'
gem 'font-awesome-rails'
gem 'good_job', '~> 4.13'
gem 'groupdate'
gem 'jbuilder', '~> 2.13'
gem 'jquery-rails'
gem 'jquery-tablesorter'
gem 'jsbundling-rails'
gem 'kramdown'
gem 'lograge'
gem 'momentjs-rails'
gem 'open311', github: 'bensheldon/open311', branch: 'api_headers'
gem 'order_query'
gem 'pg'
gem 'puma'
gem 'rack-host-redirect'
gem 'rails', '~> 8.1.0'
gem 'sass-rails'
gem 'scenic'
gem 'sentry-rails'
gem 'slim'
gem 'slim-rails'
gem 'terser'
gem 'textacular'

group :production, :staging do
  gem 'rack-timeout'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'selenium-webdriver'
end

group :development do
  gem 'annotaterb'
  gem 'listen'
  gem 'rubocop'
  gem 'rubocop-capybara'
  gem 'rubocop-factory_bot'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails'
  gem 'slim_lint', require: false
  gem 'web-console', '>= 3.3.0'
  gem 'webmock'
end

group :test do
  gem 'capybara'
  gem 'climate_control'
  gem 'launchy', require: false
  gem 'rails-controller-testing'
  gem 'rspec_junit_formatter'
  gem 'timecop'
end
