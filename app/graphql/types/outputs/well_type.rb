# frozen_string_literal: true

module Types
  module Outputs
    # The type for Well objects.
    class WellType < BaseObject
      field :id, ID, null: false
      field :created_at, String, null: false
      field :updated_at, String, null: false

      field :position, String, null: false
      field :plate_id, Integer, null: false
      field :material, MaterialUnionType, null: false
    end
  end
end
