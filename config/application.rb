require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Open311status
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    config.secret_key_base = ENV.fetch('SECRET_KEY_BASE', 'open311status-static-site')

    config.cities = YAML.load_file Rails.root.join('config', 'cities.yml')

    # Directory containing the YAML data files (checked out from the `data` branch).
    config.data_path = Pathname.new(ENV.fetch('DATA_PATH', Rails.root.join('data').to_s))
  end
end
