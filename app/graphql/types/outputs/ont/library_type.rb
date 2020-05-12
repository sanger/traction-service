# frozen_string_literal: true

module Types
  module Outputs
    module Ont
      # The type for Ont::Library objects.
      class LibraryType < CommonOutputObject
        field :name, String, null: false
        field :plate_barcode, String, null: false
        field :pool, Integer, null: false
        field :pool_size, Integer, null: false
        field :tube_barcode, String, null: true
      end
    end
  end
end
