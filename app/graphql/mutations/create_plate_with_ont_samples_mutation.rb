# frozen_string_literal: true

module Mutations
  # Mutation to create a plate with ONT samples.
  class CreatePlateWithOntSamplesMutation < BaseMutation
    argument :arguments, Types::Inputs::PlateWithSamplesInputType, required: true

    field :plate, Types::Outputs::PlateType, null: true
    field :errors, [String], null: false

    def resolve(arguments:)
      factory = Ont::PlateFactory.new(arguments.to_h)

      if factory.save
        { plate: factory.plate, errors: [] }
      else
        { plate: nil, errors: factory.errors.full_messages }
      end
    end
  end
end
