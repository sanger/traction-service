# frozen_string_literal: true

module Mutations
  # Mutation to handle the update of a Well.
  class CreatePlateWithOntSamplesMutation < BaseMutation
    argument :arguments, Types::Inputs::PlateWithSamplesInputType, required: true

    field :plate, Types::Outputs::PlateType, null: true
    field :errors, [String], null: false

    def resolve(arguments:)
      factory = Ont::RequestFactory.new(arguments.to_h)

      if factory.save
        { plate: factory.plate_factory.plate, errors: [] }
      else
        { plate: nil, errors: factory.errors.full_messages }
      end
    end
  end
end
