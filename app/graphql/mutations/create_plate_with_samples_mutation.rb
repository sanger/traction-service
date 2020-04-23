# frozen_string_literal: true

module Mutations
  # Mutation to handle the update of a Well.
  class CreatePlateWithSamplesMutation < BaseMutation
    argument :arguments, Types::Inputs::PlateWithSamplesInputType, required: true

    field :plate, Types::Outputs::PlateType, null: true
    field :errors, [String], null: false

    def resolve(arguments:)
      # TODO: Call the factory methods to create a plate with samples
      plate = Plate.create(barcode: 'TEMP-123')

      if plate.persisted?
        { plate: plate, errors: [] }
      else
        { plate: nil, errors: plate.errors.full_messages }
      end
    end
  end
end
