source 'https://rubygems.org'
ruby File.read(File.join(File.dirname(__FILE__), '.ruby-version')).strip

gem 'activerecord-explain-analyze'
gem 'activerecord-postgis-adapter'
gem 'autoprefixer-rails'
gem 'aws-sdk-s3'
gem 'babosa'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootstrap-sass'
gem 'chart-js-rails'
gem 'chartkick'
gem 'coffee-rails', '~> 4.2'
gem 'composite_primary_keys'
gem 'draper'
gem 'factory_bot_rails'
gem 'faker'
gem 'font-awesome-rails'
gem 'font_assets'
gem 'groupdate'
gem 'haml-rails'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'jquery-tablesorter'
gem 'lograge'
gem 'momentjs-rails'
gem 'open311', github: 'bensheldon/open311', branch: 'api_headers'
gem 'order_query', '~> 0.4.1'
gem 'pagy'
gem 'pg', '>= 0.18', '< 2.0'
gem 'pry-rails'
gem 'puma', '~> 3.11'
gem 'que', '~> 0.14'
gem 'rails', '~> 5.2.0'
gem 'redcarpet'
gem 'sass-rails', '~> 5.0'
gem 'scenic'
gem 'sentry-raven'
gem 'sitemap_generator'
gem 'slim-rails'
gem 'textacular'
gem 'uglifier', '>= 1.3.0'
gem 'webpacker'

group :production, :staging do
  gem 'heroku-deflater'
  gem 'rack-timeout'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'selenium-webdriver'
end

group :development do
  gem 'annotate'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
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
