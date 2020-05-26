# frozen_string_literal: true

module Types
  module Outputs
    # The type for Plate objects.
    class PlateType < CommonOutputObject
      field :barcode, String, 'The barcode of this plate.', null: false
      field :wells, [WellType], 'An array of wells that exist on this plate.', null: false
    end
  end
end
