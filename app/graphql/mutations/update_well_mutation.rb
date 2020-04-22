# frozen_string_literal: true

module Mutations
  # Mutation to handle the update of a Well.
  class UpdateWellMutation < BaseMutation
    argument :id, ID, required: true
    argument :position, String, required: false

    field :well, Types::WellType, null: true
    field :errors, [String], null: false

    def resolve(id:, position: nil)
      well = Well.find(id)
      well.position = position unless position.nil?

      if well.save
        { well: well, errors: [] }
      else
        { well: nil, errors: well.errors.full_messages }
      end
    end
  end
end
