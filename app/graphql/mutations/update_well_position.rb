# frozen_string_literal: true

module Mutations
  class UpdateWellPosition < BaseMutation
    argument :well_id, ID, required: true
    argument :position, String, required: false

    field :well, Types::WellType, null: true
    field :errors, [String], null: false

    def resolve(well_id:, position:)
      well = Well.find(well_id)
      well.position = position

      if well.save
        {
          well: well,
          errors: []
        }
      else
        {
          well: nil,
          errors: well.errors.full_messages
        }
      end
    end
  end
end
