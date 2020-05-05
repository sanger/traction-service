# frozen_string_literal: true

module Types
  module Outputs
    module Ont
      # The type for Ont::Library objects.
      class LibraryType < CommonOutputObject
        field :plate_barcode, String, null: false
        field :pool, Integer, null: false
        field :well_range, String, null: false
        field :pool_size, Integer, null: false
      end
    end
  end
end
