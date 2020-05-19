# frozen_string_literal: true

module Types
  module Inputs
    module Ont
      # The input arguments for an Ont Run.
      class RunInputType < BaseInputObject
        argument :state, Types::Enums::Ont::RunStateEnum, 'The state for the run.', required: false
        argument :flowcells, [FlowcellInputType], 'An array of flowcells to assign to the run.',
                 required: false
      end
    end
  end
end
