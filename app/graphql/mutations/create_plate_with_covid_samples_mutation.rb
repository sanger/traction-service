# frozen_string_literal: true

module Mutations
  # Mutation to handle the update of a Well.
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
        { plate: factory.plate, errors: [] }
      else
        { plate: nil, errors: factory.errors.full_messages }
      end
    end
  end
end
