# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'bootsnap', '>= 1.1.0', require: false # Reduces boot times through caching
gem 'bunny'
gem 'exception_notification'
gem 'graphql'
gem 'graphql-client'
gem 'graphql-docs'
gem 'jsonapi-resources', '~> 0.9.10'
gem 'mysql2'
gem 'puma', '~> 4.3' # Use Puma as the app server
gem 'rack-cors' # Use Rack CORS for handling CORS, making cross-origin AJAX possible
gem 'rails', '~> 6.0.3.1'
gem 'rubocop-rails'

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rails-erd'
  gem 'spring' # Spring speeds up development by keeping your application running in the background.
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'yard', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails'
end

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'shoulda-matchers'
  gem 'sqlite3'
end
