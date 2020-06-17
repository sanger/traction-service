# frozen_string_literal: true

module Types
  # The base object for GraphQL types.
  class BaseObject < GraphQL::Schema::Object
    field_class Types::BaseField
    connection_type_class(Types::Connections::BaseConnectionObject)
  end
end
