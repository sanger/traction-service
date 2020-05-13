# frozen_string_literal: true

module Types
  # Mutations.
  class MutationTypes < BaseObject
    # Ont::Plates
    field :create_plate_with_covid_samples,
          'Create a plate with a single Covid sample per well.',
          mutation: Mutations::CreatePlateWithCovidSamplesMutation

    # Ont::Libraries
    field :create_covid_libraries,
          'Create a library from a 96-well plate containing Covid samples.',
          mutation: Mutations::CreateCovidLibrariesMutation
    field :delete_covid_library,
          'Delete a covid library and containing tube',
          mutation: Mutations::DeleteCovidLibraryMutation

    # Ont::Runs
    field :create_covid_run,
          'Create a GriION run containing up to five flow cells loaded with Covid libraries.',
          mutation: Mutations::CreateCovidRunMutation
  end
end
