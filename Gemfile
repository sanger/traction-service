# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

gem 'bootsnap', '>= 1.1.0', require: false # Reduces boot times through caching
gem 'bunny'
gem 'exception_notification'
# 0.10.5 Results in MySQL syntax error on several tests when run against a MySQL
# There is a 'monkey patch' for this in config/intializers/jsonapi_resources:15-63
gem 'jsonapi-resources'
gem 'mysql2'
gem 'puma', '~> 6.0' # Use Puma as the app server
gem 'rack-cors' # Use Rack CORS for handling CORS, making cross-origin AJAX possible
gem 'rails', '~> 7.1.1'

group :development do
  gem 'listen'
  gem 'rails-erd'
  gem 'spring' # Spring speeds up development by keeping your application running in the background.
  gem 'spring-watcher-listen'
  gem 'yard', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails'
end

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
  gem 'sqlite3'
end

gem 'flipper', '~> 0.25.0'
gem 'flipper-active_record', '~> 0.25.0'
gem 'flipper-api', '~> 0.25.0'
gem 'flipper-ui', '~> 0.25.3'
