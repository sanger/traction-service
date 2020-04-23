# frozen_string_literal: true

module Types
  module Outputs
    # The type for Plate objects.
    class PlateType < BaseObject
      field :id, ID, null: false
      field :created_at, String, null: false
      field :updated_at, String, null: false

      field :barcode, String, null: false
      field :wells, [WellType], null: false
    end
  end
end
