# frozen_string_literal: true

module Mutations
  # Mutation to create a plate with samples in wells.
  class CreatePlateWithSamplesMutation < BaseMutation
    argument :study_type, Types::Enums::Ont::StudyTypeEnum,
             'The study type for the samples (not currently used).', required: false
    argument :arguments, Types::Inputs::Ont::PlateWithSamplesInputType,
             'Arguments describing the plate, wells and samples to create a plate for.',
             required: true

    field :plate, Types::Outputs::PlateType, 'The generated plate, or nil if errors were thrown.',
          null: true
    field :errors, [String], 'An array of error messages thrown when creating the plate.',
          null: false

    def resolve(arguments:)
      factory = Ont::PlateWithSamplesFactory.new(arguments.to_h)
      factory.process
      plate = factory.save

      if plate
        resolved_plate = Plate.resolved_query.find_by(id: plate.id)
        { plate: resolved_plate, errors: [] }
      else
        { plate: nil, errors: factory.errors.full_messages }
      end
    end
  end
end
