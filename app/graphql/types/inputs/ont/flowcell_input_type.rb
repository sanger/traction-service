# frozen_string_literal: true

module Types
  module Inputs
    module Ont
      # The input arguments for Ont Flowcells.
      class FlowcellInputType < BaseInputObject
        argument :position, Integer, required: false
        argument :library_name, String, required: false
      end
    end
  end
end
