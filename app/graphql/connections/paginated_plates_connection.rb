# frozen_string_literal: true

module Connections
  # A wrapper for edges in a plates connection.
  class PlateEdge < GraphQL::Types::Relay::BaseEdge
    node_type Types::Outputs::PlateType
  end

  # A connection definition to paginate plates with.
  class PaginatedPlatesConnection < GraphQL::Types::Relay::BaseConnection
    edge_type PlateEdge
  end
end
