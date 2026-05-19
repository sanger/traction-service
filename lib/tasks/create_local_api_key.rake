# frozen_string_literal: true

# This Rake task creates a local API key for testing purposes.
namespace :local_api_key do
  desc 'Create local API keys for testing'
  task create: :environment do
    # Initially created for local development with tol-lab-share, but can be used for any local testing requiring API key authentication.
    default_app = ApiApplication.create(name: 'Default application', contact_name: 'default-application')
    ApiKey.issue!(api_application: default_app, plaintext_key: 'traction-development')

    puts '-> Local api key created'
  end
end
