# frozen_string_literal: true

module Types
  # The type for Well mutations.
  class WellMutationType < BaseObject
    field :update_well_position, mutation: Mutations::UpdateWellPositionMutation
  end
end
