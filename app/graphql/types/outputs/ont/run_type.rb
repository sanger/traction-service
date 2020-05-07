# frozen_string_literal: true

module Types
  module Outputs
    module Ont
      # The type for Ont::Run objects.
      class RunType < CommonOutputObject
        field :instrument_name, String, null: false
        field :state, Integer, null: false
        field :deactivated_at, String, null: true
        field :flowcells, [FlowcellType], null: false
      end
    end
  end
end
