# frozen_string_literal: true

module Types
  # Mutations.
  class MutationTypes < BaseObject
    # Plates
    field :create_plate_with_covid_samples,
          'Create a plate with a single Covid sample per well.',
          mutation: Mutations::CreatePlateWithCovidSamplesMutation

    # Libraries
    field :create_covid_libraries,
          'Create a library from a 96-well plate containing Covid samples.',
          mutation: Mutations::CreateCovidLibrariesMutation
  end
end
