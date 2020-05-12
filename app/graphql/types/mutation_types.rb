# frozen_string_literal: true

module Types
  # Mutations.
  class MutationTypes < BaseObject
    # Plates
    field :create_plate_with_covid_samples,
          mutation: Mutations::CreatePlateWithCovidSamplesMutation do
      description 'Create a plate with a single Covid sample per well.'
    end

    # Libraries
    field :create_covid_libraries, mutation: Mutations::CreateCovidLibrariesMutation do
      description 'Create a library from a 96-well plate containing Covid samples.'
    end
  end
end
