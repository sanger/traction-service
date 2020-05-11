# frozen_string_literal: true

module Mutations
  # Mutation to create a COVID run.
  class CreateCovidRunMutation < BaseMutation
    argument :flowcells, [Types::Inputs::Ont::FlowcellInputType], required: true

    field :run, Types::Outputs::Ont::RunType, null: true
    field :errors, [String], null: false

    def resolve(flowcells:)
      factory = Ont::RunFactory.new(flowcells.to_a)

      if factory.save
        { run: factory.run, errors: [] }
      else
        { run: nil, errors: factory.errors.full_messages }
      end
    end
  end
end
