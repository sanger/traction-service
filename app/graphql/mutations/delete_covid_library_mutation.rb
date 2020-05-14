# frozen_string_literal: true

module Mutations
  # Mutation to delete a single ONT library
  class DeleteCovidLibraryMutation < BaseMutation
    argument :library_name, String, 'The name of the library to delete.', required: true

    field :success, Boolean, 'Whether the library was successfully deleted.', null: false
    field :errors, [String], 'An array of error messages thrown when deleting the library',
          null: false

    def resolve(library_name:)
      library = Ont::Library.find_by(library_name: library_name)

      if library.nil?
        { success: false, errors: ["Library with name '#{library_name}' does not exist"] }
      elsif !library.flowcell.nil?
        { success: false, errors: ['Cannot delete a library that is used in a run'] }
      else
        tube = tube.find_by(barcode: library.tube_barcode)
        ActiveRecord::Base.transaction do
          tube.destroy!
          library.destroy!
        end
        { success: true, errors: [] }
      end
    rescue ActiveRecord::RecordNotDestroyed
      { success: false, errors: library.errors.full_messages + tube.errors.full_messages }
    end
  end
end
