# frozen_string_literal: true

namespace :factory_bot do
  desc 'Verify that all FactoryBot factories are valid'
  task lint: :environment do
    require 'factory_bot'

    FactoryBot.factories.clear
    FactoryBot.find_definitions

    if Rails.env.test?
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.cleaning do
        puts 'Linting factories.'
        FactoryBot.lint
        puts 'Linted'
      end
    else
      system("bundle exec rake factory_bot:lint RAILS_ENV='test'")
    end
  end
end
