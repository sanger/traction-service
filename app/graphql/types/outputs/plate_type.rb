# frozen_string_literal: true

module Types
  module Outputs
    # The type for Plate objects.
    class PlateType < CommonOutputObject
      field :barcode, String, null: false
      field :wells, [WellType], null: false
    end
  end
end
