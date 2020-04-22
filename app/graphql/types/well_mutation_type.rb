module Types
  class WellMutationType < BaseObject
    field :update_well_position, mutation: Mutations::UpdateWellPosition
  end
end
