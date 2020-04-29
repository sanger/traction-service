# frozen_string_literal: true

module Types
  module Outputs
    # The type for Plate objects.
    class LibraryType < CommonOutputObject
      field :id, Int, null: false
    end
  end
end
