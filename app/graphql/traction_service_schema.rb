# frozen_string_literal: true

class TractionServiceSchema < GraphQL::Schema
  # Queries
  query(Types::WellQueryType)

  # Mutations
  mutation(Types::WellMutationType)

  # Opt in to the new runtime (default in future graphql-ruby versions)
  use GraphQL::Execution::Interpreter
  use GraphQL::Analysis::AST

  # Add built-in connections for pagination
  use GraphQL::Pagination::Connections
end
