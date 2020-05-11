# frozen_string_literal: true

module Types
  # Mutations.
  class MutationTypes < BaseObject
    # Plates
    field :create_plate_with_covid_samples, mutation: Mutations::CreatePlateWithCovidSamplesMutation
    # Libraries
    field :create_covid_libraries, mutation: Mutations::CreateCovidLibrariesMutation
  end
end
