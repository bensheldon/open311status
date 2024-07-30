# frozen_string_literal: true

if defined? Sentry
  Sentry.init do |config|
    config.enabled_environments = %w[production staging]
    config.excluded_exceptions = Sentry::Configuration::IGNORE_DEFAULT + Sentry::Rails::IGNORE_DEFAULT + %w[
      ActionController::UnknownFormat
      Rack::Timeout::RequestTimeoutError
      Rack::Timeout::RequestExpiryError
    ]

    # use Rails' parameter filter to sanitize the event
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters - [:name, :filename])
    config.before_send = lambda do |event, _hint|
      filter.filter(event.to_hash)
    end
  end
end
