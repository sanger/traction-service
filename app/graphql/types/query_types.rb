# frozen_string_literal: true

module Types
  # The type for defining GraphQL queries.
  class QueryTypes < BaseObject
    # Wells

    field :well, Types::Outputs::WellType, null: true do
      description 'Find a Well by ID.'
      argument :id, ID, required: true
    end

    def well(id:)
      return nil unless Well.exists?(id)

      Well.find(id)
    end

    field :wells, [Types::Outputs::WellType], null: false do
      description 'Find all Wells.'
      argument :plate_id, Int, required: false
    end

    def wells(plate_id: nil)
      if plate_id.nil?
        Well.all
      else
        Well.where(plate_id: plate_id)
      end
    end

    # Plates

    field :plates, [Types::Outputs::PlateType], null: false do
      description 'Find all Plates.'
    end

    def plates
      Plate.all
    end

    # Ont::Libraries

    field :ont_libraries, [Types::Outputs::Ont::LibraryType], null: false do
      description 'Find all Ont Libraries.'
    end

    def ont_libraries
      Ont::Library.all
    end
  end
end
