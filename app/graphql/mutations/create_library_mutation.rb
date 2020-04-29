# frozen_string_literal: true

module Mutations
  # Mutation to handle the update of a Well.
  class CreateLibraryMutation < BaseMutation
    argument :arguments, Types::Inputs::LibraryInputType, required: true

    field :library, Types::Outputs::LibraryType, null: true
    field :errors, [String], null: false

    def resolve(arguments:)
      plate_id = arguments.plate_id
    end
  end
end
