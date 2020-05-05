# frozen_string_literal: true

module Mutations
  # Mutation to handle the update of a Well.
  class CreateOntLibrariesMutation < BaseMutation
    argument :arguments, Types::Inputs::Ont::LibrariesInputType, required: true

    field :tubes, [Types::Outputs::TubeType], null: false
    field :errors, [String], null: false

    def resolve(arguments:)
      factory = Ont::LibraryFactory.new(arguments.to_h)

      if factory.save
        { tubes: factory.tubes, errors: [] }
      else
        { tubes: [], errors: factory.errors.full_messages }
      end
    end
  end
end
