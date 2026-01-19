# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '4.0.0'

gem 'avro'
gem 'bootsnap', '>= 1.1.0', require: false # Reduces boot times through caching
gem 'bunny'
gem 'csv'
gem 'exception_notification'
gem 'mysql2'
gem 'puma' # Use Puma as the app server
gem 'rack-cors' # Use Rack CORS for handling CORS, making cross-origin AJAX possible
gem 'rack-session' # Use Rack Session for session management. Needed for flipper
gem 'rails', '~> 8.0.2'
gem 'sanger-jsonapi-resources', '~> 0.2.1'
gem 'syslog' # No longer part of the default gems in Ruby 3.4

group :development do
  gem 'listen'
  gem 'rails-erd'
  gem 'spring' # Spring speeds up development by keeping your application running in the background.
  gem 'spring-watcher-listen'
  gem 'yard', require: false
end

group :test do
  gem 'database_cleaner'
  # without require: false it will load the gem before the rails environment
  gem 'factory_bot_rails', require: false
  gem 'rubocop-factory_bot', require: false
end

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'shoulda-matchers'
  gem 'webmock'
end

gem 'flipper'
gem 'flipper-active_record'
gem 'flipper-api'
gem 'flipper-ui'
