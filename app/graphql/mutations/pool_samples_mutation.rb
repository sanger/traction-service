# frozen_string_literal: true

module Mutations
  # Mutation to handle the update of a Well.
  class PoolSamplesMutation < BaseMutation
    argument :arguments, Types::Inputs::PoolSamplesInputType, required: true

    field :library, [Types::Outputs::LibraryType], null: true
    field :errors, [String], null: false

    def resolve(arguments:)
      debugger
      # arguments.plate_id
    end
  end
end
