# frozen_string_literal: true

module Types
  module Outputs
    # The type for Tube objects.
    class TubeType < CommonOutputObject
      field :barcode, String, null: false
      field :materials, [MaterialUnionType], null: true
    end
  end
end
