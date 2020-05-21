# frozen_string_literal: true

module Types
  # Mutations.
  class MutationTypes < BaseObject
    # Ont::Plates
    field :create_plate_with_samples,
          'Create a plate with a single sample per well.',
          mutation: Mutations::CreatePlateWithSamplesMutation

    # Ont::Libraries
    field :create_ont_libraries,
          'Create an ONT library from a 96-well plate containing samples.',
          mutation: Mutations::CreateOntLibrariesMutation
    field :delete_ont_library,
          'Delete an ONT library and containing tube',
          mutation: Mutations::DeleteOntLibraryMutation

    # Ont::Runs
    field :create_ont_run,
          'Create a GridION run containing up to five flow cells loaded with ONT libraries.',
          mutation: Mutations::CreateOntRunMutation

    field :update_ont_run,
          'Update an existing GridION run with new properties.',
          mutation: Mutations::UpdateOntRunMutation
  end
end
