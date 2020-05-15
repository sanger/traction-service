# frozen_string_literal: true

module Types
  module Outputs
    module Ont
      # The type for Ont::Flowcell objects.
      class FlowcellType < CommonOutputObject
        field :position, Integer, 'The numerical position of this flowcell in the GridION machine.',
              null: false
        field :uuid, String, 'The UUID of this flowcell.', null: false
        field :library, LibraryType, 'The library loaded onto this flowcell.', null: false
      end
    end
  end
end
