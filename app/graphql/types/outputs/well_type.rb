# frozen_string_literal: true

module Types
  module Outputs
    # The type for Well objects.
    class WellType < CommonOutputObject
      field :position, String, null: false
      field :plate_id, Integer, null: false
      field :materials, [MaterialUnionType], null: true
    end
  end
end
