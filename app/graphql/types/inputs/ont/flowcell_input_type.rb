# frozen_string_literal: true

module Types
  module Inputs
    module Ont
      # The input arguments for Ont Flowcells.
      class FlowcellInputType < BaseInputObject
        argument :position, Integer,
                 'The numerical position of this flowcell in the GriION machine', required: false
        argument :library_name, String, 'The name of the library to be loaded in this flowcell.',
                 required: false
      end
    end
  end
end
