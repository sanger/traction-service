# frozen_string_literal: true

module Mutations
  # Mutation to handle the update of a Well.
  class CreatePlateWithOntSamplesMutation < BaseMutation
    argument :arguments, Types::Inputs::PlateWithSamplesInputType, required: true

    field :plate, Types::Outputs::PlateType, null: true
    field :errors, [String], null: false

    def resolve(arguments:)
      #factory = Ont::RequestFactory.new(arguments.to_h)
      plate = Plate.create(barcode: arguments[:barcode], wells: [])

      if plate.save
        { plate: plate, errors: [] } # TODO: get the plate from the factory
      else
        { plate: nil, errors: [] } # TODO: get the errors back from the factory
      end
    end
  end
end
