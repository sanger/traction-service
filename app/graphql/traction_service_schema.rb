# frozen_string_literal: true

# The Schema for the GraphQL endpoint in Traction Service.
class TractionServiceSchema < GraphQL::Schema
  query(Types::QueryTypes)
  mutation(Types::MutationTypes)
end
