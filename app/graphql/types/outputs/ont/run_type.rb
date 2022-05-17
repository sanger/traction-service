# frozen_string_literal: true

module Types
  module Outputs
    module Ont
      # The type for Ont::Run objects.
      class RunType < CommonOutputObject
        field :state, Types::Enums::Ont::RunStateEnum, 'The state of this run.', null: false
        field :deactivated_at, String, 'The date this run was deactivated.', null: true
        field :flowcells, [FlowcellType], 'An array of flowcells in this run.', null: false
        field :experiment_name, String, 'The experiment name of this run.', null: false
      end
    end
  end
end
