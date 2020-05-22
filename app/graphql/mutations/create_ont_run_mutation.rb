# frozen_string_literal: true

module Mutations
  # Mutation to create an ONT run.
  class CreateOntRunMutation < BaseOntRunMutation
    argument :study_type, Types::Enums::Ont::StudyTypeEnum,
             'The study type for the run (not currently used).', required: false
    argument :flowcells, [Types::Inputs::Ont::FlowcellInputType],
             'An array of flowcells to include in the run.', required: true

    field :run, Types::Outputs::Ont::RunType, 'The generated Run, or null if errors were thrown.',
          null: true
    field :errors, [String], 'An array of error messages thrown while creating the run.',
          null: false

    def resolve(flowcells:)
      factory = Ont::RunFactory.new(flowcells.to_a)

      if factory.save
        send_messages(run: factory.run)
        { run: factory.run, errors: [] }
      else
        { run: nil, errors: factory.errors.full_messages }
      end
    end
  end
end
