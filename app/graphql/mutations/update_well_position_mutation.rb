# frozen_string_literal: true

module Mutations
  # Mutation to handle the update of a well position for a well with a given ID.
  class UpdateWellPositionMutation < BaseMutation
    argument :id, ID, required: true
    argument :position, String, required: true

    field :well, Types::WellType, null: true
    field :errors, [String], null: false

    def resolve(id:, position:)
      well = Well.find(id)

      if well.update(position: position)
        { well: well, errors: [] }
      else
        { well: nil, errors: well.errors.full_messages }
      end
    end
  end
end
