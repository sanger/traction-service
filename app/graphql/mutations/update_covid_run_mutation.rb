# frozen_string_literal: true

module Mutations
  # Mutation to update a COVID run.
  class UpdateCovidRunMutation < BaseMutation
    argument :id, ID, 'The ID of the Ont Run to update.', required: true
    argument :properties, Types::Inputs::Ont::RunInputType, 'The properties to update on the run.',
             required: true

    field :run, Types::Outputs::Ont::RunType, 'The updated Run, or null if errors were thrown.',
          null: true
    field :errors, [String], 'An array of error messages thrown while updating the run.',
          null: false

    def resolve(id:, properties:)
      run = Ont::Run.find_by(id: id)
      return { run: nil, errors: ["Couldn't find the specified run."] } if run.nil?

      { run: run, errors: [] }
    end
  end
end
