# frozen_string_literal: true

module Types
  # The base union for GraphQL.
  class BaseUnion < GraphQL::Schema::Union
    connection_type_class(Types::Connections::BaseConnectionObject)
  end
end
