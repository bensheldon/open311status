source 'https://rubygems.org'
ruby File.read(File.join(File.dirname(__FILE__), '.ruby-version')).strip
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'autoprefixer-rails'
gem 'babosa'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootstrap-sass'
gem 'chart-js-rails'
gem 'chartkick'
gem 'coffee-rails', '~> 4.2'
gem 'draper'
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
gem 'pg', '>= 0.18', '< 2.0'
gem 'pry-rails'
gem 'puma', '~> 3.11'
gem 'rails', '~> 5.2.0'
gem 'redcarpet'
gem 'sass-rails', '~> 5.0'
gem 'sentry-raven'
gem 'slim-rails'
gem 'uglifier', '>= 1.3.0'
gem 'webpacker'

group :production, :staging do
  gem 'heroku-deflater'
  gem 'rack-timeout'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'faker'
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
  gem 'factory_bot_rails'
  gem 'launchy', require: false
  gem 'rails-controller-testing'
  gem 'rspec_junit_formatter'
end
