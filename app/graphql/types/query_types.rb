# frozen_string_literal: true

module Types
  # The type for Well queries.
  class QueryTypes < BaseObject
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

    field :plates, [Types::Outputs::PlateType], null: false do
      description 'Find all Plates.'
    end

    def plates
      Plate.all
    end

    field :libraries, [Types::Outputs::LibraryType], null: false do
      description 'Find all Libraries'
    end

    def libraries
      # ONT::Library.all
      [
        { id: 1, tube_barcode: 'TRAC-2-1', plate_barcode: 'TRAC-1-1', pool: 1,
          name: 'TRAC-1-1-1', wells: 'A1-H3', tag_set: 24 },
        { id: 2, tube_barcode: 'TRAC-2-2', plate_barcode: 'TRAC-1-1', pool: 2,
          name: 'TRAC-1-1-2', wells: 'A4-H6', tag_set: 24 },
        { id: 3, tube_barcode: 'TRAC-2-3', plate_barcode: 'TRAC-1-1', pool: 3,
          name: 'TRAC-1-1-3', wells: 'A7-H9', tag_set: 24 },
        { id: 4, tube_barcode: 'TRAC-2-4', plate_barcode: 'TRAC-1-1', pool: 4,
          name: 'TRAC-1-1-4', wells: 'A10-H12', tag_set: 24 },
        { id: 5, tube_barcode: 'TRAC-2-5', plate_barcode: 'TRAC-1-2', pool: 1,
          name: 'TRAC-1-2-1', wells: 'A1-H12', tag_set: 96 }
      ]
    end
  end
end
