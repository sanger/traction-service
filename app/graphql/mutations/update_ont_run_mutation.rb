# frozen_string_literal: true

module Mutations
  # Mutation to update an ONT run.
  class UpdateOntRunMutation < BaseOntRunMutation
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

      run_was_updated = false
      run_was_updated ||= update_run_state(run, properties.state)
      errors = update_run_flowcells(run, properties.flowcells)
      run_was_updated ||= errors.nil?

      if errors&.any?
        { run: nil, errors: errors }
      else
        send_messages(run: run) if run_was_updated
        { run: run, errors: [] }
      end
    end

    private

    def update_run_state(run, state)
      return false if state.nil?

      run.update(state: state)

      true
    end

    def update_run_flowcells(run, flowcell_specs)
      return [] if flowcell_specs.nil?
      return ['Invalid empty array provided for updated flowcells.'] if flowcell_specs.count == 0

      # Create new flowcells and attempt to save them
      factory = Ont::RunFactory.new(flowcell_specs, run)
      return factory.errors.full_messages unless factory.save

      nil
    end
  end
end
