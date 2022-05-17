# frozen_string_literal: true

module Types
  # The base interface for GraphQL.
  module BaseInterface
    include GraphQL::Schema::Interface

    field_class Types::BaseField
    connection_type_class(Types::Connections::BaseConnectionObject)
  end
end
