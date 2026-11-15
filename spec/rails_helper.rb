# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

Rails.root.glob('spec/support/**/*.rb').each { |f| require f }

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include ActiveSupport::Testing::TimeHelpers

  # Specs against the Parklife build (spec/build) only run with `--tag build`.
  config.filter_run_excluding :build unless config.inclusion_filter[:build]
end
