# frozen_string_literal: true

module Types
  module Outputs
    # The type for Well objects.
    class WellType < CommonOutputObject
      field :position, String, 'The description of the position for this well on the plate.',
            null: false
      field :plate_id, ID, 'The ID of the plate this well belongs to.', null: false
      field :materials, [MaterialUnionType], 'The materials contained within this well.', null: true
    end
  end
end
