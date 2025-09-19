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

# Disable cops as we want to match the original coding as closely as possible
# rubocop:disable all
# Monkey patch MySQL compatibility to default to no quoting:
# include_related[key][include_related]
class JSONAPI::ActiveRelationResource
  def self.sql_field_with_alias(table, field, quoted = false)
    Arel.sql("#{concat_table_field(table, field, quoted)} AS #{alias_table_field(table, field, quoted)}")
  end
end

# TODO: This is a temporary fix to allow the use of 422 Unprocessable Entity status code
# in JSONAPI::Resources. This should be removed once the issue is resolved in the
# JSONAPI::Resources gem.
# See:
# https://github.com/cerebris/jsonapi-resources/issues/1456
# Rack::Utils::SYMBOL_TO_STATUS_CODE[:unprocessable_entity] = 422

# rubocop:enable
