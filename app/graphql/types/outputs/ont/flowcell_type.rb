# frozen_string_literal: true

module Types
  module Outputs
    module Ont
      # The type for Ont::Flowcell objects.
      class FlowcellType < CommonOutputObject
        field :position, Integer, null: false
        field :uuid, String, null: false
        field :library, LibraryType, null: false
      end
    end
  end
end
