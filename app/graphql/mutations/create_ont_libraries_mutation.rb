# frozen_string_literal: true

module Mutations
  # Mutation to create ONT libraries from a plate.
  class CreateOntLibrariesMutation < BaseMutation
    argument :arguments, Types::Inputs::Ont::LibraryCreationArgumentsInputType,
             'Arguments describing the source for libraries to be created.', required: true

    field :tubes, [Types::Outputs::TubeType],
          'An array of tubes containing the generated libraries, or null if errors were thrown.',
          null: true
    field :errors, [String], 'An array of error messages thrown when creating libraries.',
          null: false

    def resolve(arguments:)
      factory = Ont::LibraryFactory.new(arguments.to_h)

      if factory.save
        resolved_tube = Tube.resolved_query.find_by(id: factory.tube.id)
        { tubes: [resolved_tube], errors: [] }
      else
        { tubes: nil, errors: factory.errors.full_messages }
      end
    end
  end
end
