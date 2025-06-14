# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TractionService
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.generators do |g|
      g.test_framework :rspec,
                       routing_specs: false,
                       controller_specs: false,
                       request_specs: true
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    config.mailer = config_for(:mailer)

     # Rails 5
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :put, :patch, :options]
      end
    end

    # RabbitMQ config
    config.bunny = config_for(:bunny)

    config.pacbio_instrument_types = config_for(:pacbio_instrument_types)

    config.pacbio_smrt_link_versions = config_for(:pacbio_smrt_link_versions)

    # Pacbio default request cost code
    config.pacbio_request_cost_code = 'S4699'

    # Fix for Psych::DisallowedClass. Added the four top classes as this may guard against hidden errors.
    config.active_record.yaml_column_permitted_classes = [Symbol, Hash, Array, ActiveSupport::HashWithIndifferentAccess, BigDecimal]
  end
end
