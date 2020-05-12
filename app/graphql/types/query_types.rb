# frozen_string_literal: true

module Types
  # The type for defining GraphQL queries.
  class QueryTypes < BaseObject
    # Wells

    field :well, Types::Outputs::WellType, 'Find a Well by ID.', null: true do
      argument :id, ID, 'The ID of the Well to find.', required: true
    end

    def well(id:)
      return nil unless Well.exists?(id)

      Well.find(id)
    end

    field :wells, [Types::Outputs::WellType], 'Find all Wells.', null: false do
      argument :plate_id, ID, 'The Plate ID to fetch wells for.', required: false
    end

    def wells(plate_id: nil)
      if plate_id.nil?
        Well.all
      else
        Well.where(plate_id: plate_id)
      end
    end

    # Plates

    field :plates, [Types::Outputs::PlateType], 'Find all Plates.', null: false

    def plates
      Plate.all
    end

    # Ont::Libraries

    field :ont_libraries, [Types::Outputs::Ont::LibraryType], 'Find all Ont Libraries.', null: false

    def ont_libraries
      Ont::Library.all
    end
  end
end
