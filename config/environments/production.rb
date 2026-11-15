Rails.application.configure do
  # Production is only used to generate the static site with Parklife (bin/static-build).
  config.enable_reloading = false
  config.eager_load = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.public_file_server.enabled = true

  config.assets.js_compressor = :terser
  config.assets.css_compressor = :sass
  # Assets are precompiled inside the Parklife build process, after boot.
  config.assets.compile = true
  config.force_ssl = false

  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.logger = ActiveSupport::TaggedLogging.logger($stdout)

  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
end
