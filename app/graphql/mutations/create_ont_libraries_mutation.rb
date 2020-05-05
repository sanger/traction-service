# frozen_string_literal: true

module Mutations
  # Mutation to handle the update of a Well.
  class CreateOntLibrariesMutation < BaseMutation
    argument :arguments, Types::Inputs::Ont::LibrariesInputType, required: true

    field :libraries, [Types::Outputs::Ont::LibraryType], null: false
    field :errors, [String], null: false

    def resolve(arguments:)
      factory = Ont::LibraryFactory.new(arguments.to_h)

      if factory.save
        { libraries: factory.libraries, errors: [] }
      else
        { libraries: [], errors: factory.errors.full_messages }
      end
    end
  end
end
