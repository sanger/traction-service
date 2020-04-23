# frozen_string_literal: true

module Types
  # The type for Well queries.
  class QueryTypes < BaseObject
    field :well, Types::Outputs::WellType, null: true do
      description 'Find a Well by ID.'
      argument :id, ID, required: true
    end

    def well(id:)
      Well.find(id)
    end

    field :wells, [Types::Outputs::WellType], null: false do
      description 'Find all wells, optionally those associated with a plate.'
      argument :plate_id, Int, required: false
    end

    def wells(plate_id: nil)
      wells = Well.all
      wells = wells.select { |well| well.plate_id == plate_id } unless plate_id.nil?
      wells
    end
  end
end
