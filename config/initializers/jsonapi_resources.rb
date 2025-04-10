# frozen_string_literal: true

JSONAPI.configure do |config|
  # :underscored_key, :camelized_key, :dasherized_key, or custom
  config.json_key_format = :underscored_key
  config.route_format = :underscored_route
  config.default_page_size = 1000
  # If we apply a filter that returns more than 1000 results some will be hidden
  # from the user. May need to address in future
  config.maximum_page_size = 1000
  # Enables the requestor to know the total number of pages
  config.top_level_meta_include_page_count = true

  # TODO: we have to set this to false for tests. Why?
  config.warn_on_missing_routes = false
end
