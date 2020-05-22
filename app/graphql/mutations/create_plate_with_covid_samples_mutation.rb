# frozen_string_literal: true

module Mutations
  # Mutation to create a plate with ONT samples.
  class CreatePlateWithCovidSamplesMutation < BaseMutation
    argument :arguments, Types::Inputs::Ont::PlateWithSamplesInputType,
             'Arguments describing the plate, wells and samples to create a plate for.',
             required: true

    field :plate, Types::Outputs::PlateType, 'The generated plate, or nil if errors were thrown.',
          null: true
    field :errors, [String], 'An array of error messages thrown when creating the plate.',
          null: false

    def resolve(arguments:)
      factory = Ont::PlateFactory.new(arguments.to_h)

      if factory.save
        resolved_plate = Plate.resolved_query.find_by(id: factory.plate.id)
        { plate: resolved_plate, errors: [] }
      else
        { plate: nil, errors: factory.errors.full_messages }
      end
    end
  end
end
