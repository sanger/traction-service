# frozen_string_literal: true

module Types
  # Mutations.
  class MutationTypes < BaseObject
    # Ont::Plates
    field :create_plate_with_ont_samples, mutation: Mutations::CreatePlateWithOntSamplesMutation

    # Ont::Libraries
    field :create_ont_libraries, mutation: Mutations::CreateOntLibrariesMutation

    # Ont::Runs
    field :create_covid_run, mutation: Mutations::CreateCovidRunMutation
  end
end
