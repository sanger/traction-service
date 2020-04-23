# frozen_string_literal: true

module Types
  # Mutations.
  class MutationTypes < BaseObject
    # Plates
    field :create_plate_with_samples, mutation: Mutations::CreatePlateWithSamplesMutation

    # Wells
    field :update_well, mutation: Mutations::UpdateWellMutation
  end
end
