# frozen_string_literal: true

module Mutations
  # Mutation to create a COVID run.
  class CreateCovidRunMutation < BaseCovidRunMutation
    argument :flowcells, [Types::Inputs::Ont::FlowcellInputType],
             'An array of flowcells to include in the run.', required: true

    field :run, Types::Outputs::Ont::RunType, 'The generated Run, or null if errors were thrown.',
          null: true
    field :errors, [String], 'An array of error messages thrown while creating the run.',
          null: false

    def resolve(flowcells:)
      factory = Ont::RunFactory.new(flowcells.to_a)

      if factory.save
        resolved_run = Ont::Run.resolved_query.find_by(id: factory.run.id)
        send_messages(resolved_run: resolved_run)
        { run: resolved_run, errors: [] }
      else
        { run: nil, errors: factory.errors.full_messages }
      end
    end
  end
end
