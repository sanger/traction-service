# frozen_string_literal: true

module Mutations
  # Mutation to handle the update of a Well.
  class CreateCovidLibrariesMutation < BaseMutation
    argument :arguments, Types::Inputs::Ont::LibraryCreationArgumentsInputType, required: true

    field :tubes, [Types::Outputs::TubeType], null: true
    field :errors, [String], null: false

    def resolve(arguments:)
      factory = Ont::LibraryFactory.new(arguments.to_h)

      if factory.save
        { tubes: [factory.tube], errors: [] }
      else
        { tubes: nil, errors: factory.errors.full_messages }
      end
    end
  end
end
