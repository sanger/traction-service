# frozen_string_literal: true

module Types
  module Outputs
    # The type for Library objects.
    class LibraryType < CommonOutputObject
      field :id, Int, null: false
      field :tubeBarcode, String, null: true
      field :plateBarcode, String, null: true
      field :pool, String, null: true
      field :name, String, null: true
      field :wells, String, null: true
      field :tagSet, Integer, null: true
    end
  end
end
