# frozen_string_literal: true

module Mutations
  # Mutation to handle the creation of a library(s), by pooling samples
  class PoolSamplesMutation < BaseMutation
    argument :arguments, Types::Inputs::PoolSamplesInputType, required: true

    field :library, [Types::Outputs::LibraryType], null: true
    field :errors, [String], null: false

    # def resolve(arguments:)
    #   debugger
    # end
  end
end
