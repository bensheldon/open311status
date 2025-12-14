require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Open311status
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    config.active_job.queue_adapter = :good_job

    config.secrets = config_for(:secrets)
    config.secret_key_base = config.secrets[:secret_key_base]
    def secrets
      config.secrets
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.cities = YAML.load_file Rails.root.join('config', 'cities.yml')

    config.action_mailer.deliver_later_queue_name = 'default'
    config.action_mailer.default_url_options = {
      host: Rails.application.secrets.default_host
    }

    config.paths.add 'app/decorators/collections', eager_load: true
  end
end
