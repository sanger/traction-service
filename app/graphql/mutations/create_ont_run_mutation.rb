# frozen_string_literal: true

module Mutations
  # Mutation to create an ONT run.
  class CreateOntRunMutation < BaseMutation
    argument :flowcells, [Types::Inputs::Ont::FlowcellInputType], required: true

    field :run, Types::Outputs::Ont::RunType, null: true
    field :errors, [String], null: false

    def resolve(flowcells:)
      flowcells.first # Make Rubocop stop warning about unused argument
      { run: Ont::Run.create(instrument_name: 'GridION'), errors: [] }

      # factory = Ont::RunFactory.new(arguments.to_h)

      # if factory.save
      #   { run: factory.run, errors: [] }
      # else
      #   { run: nil, errors: ['Factory not available yet'] } # factory.errors.full_messages }
      # end
    end
  end
end
