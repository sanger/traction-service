# frozen_string_literal: true

module Types
  # The type for Well queries.
  class WellQueryType < BaseObject
    field :well, WellType, null: true do
      description 'Find a Well by ID.'
      argument :id, ID, required: true
    end

    def well(id:)
      Well.find(id)
    end

    field :wells, [WellType], null: false do
      description 'Find all wells, optionally those associated with a plate.'
      argument :plate_id, Int, required: false
    end

    def wells(plate_id: nil)
      if plate_id.nil?
        Well.all
      else
        Well.where(plate_id: plate_id)
      end
    end
  end
end
