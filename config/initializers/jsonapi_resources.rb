# frozen_string_literal: true

JSONAPI.configure do |config|
  #:underscored_key, :camelized_key, :dasherized_key, or custom
  config.json_key_format = :underscored_key
  config.route_format = :underscored_route

  # TODO: we have to set this to false for tests. Why?
  config.warn_on_missing_routes = false
end
