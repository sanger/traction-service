# frozen_string_literal: true

module Types
  module Outputs
    # The type for Tube objects.
    class TubeType < CommonOutputObject
      field :barcode, String, 'The barcode of this tube.', null: false
      field :materials, [MaterialUnionType], 'The materials contained in this tube.', null: true
    end
  end
end
