# frozen_string_literal: true

module Mutations
  # Mutation to delete a single ONT library
  class DeleteOntLibraryMutation < BaseMutation
    argument :library_name, String, 'The name of the library to delete.', required: true

    field :success, Boolean, 'Whether the library was successfully deleted.', null: false
    field :errors, [String], 'An array of error messages thrown when deleting the library.',
          null: false

    def resolve(library_name:)
      library = Ont::Library.find_by(name: library_name)

      if library.nil?
        { success: false, errors: ["Library with name '#{library_name}' does not exist"] }
      elsif !library.flowcell.nil?
        { success: false, errors: ['Cannot delete a library that is used in a run'] }
      else
        error = destory_library(library: library)
        error.nil? ? { success: true, errors: [] } : { success: false, errors: [error] }
      end
    end

    def destory_library(library:)
      ActiveRecord::Base.transaction do
        library.container&.destroy!
        library.destroy!
      end
      nil
    rescue ActiveRecord::RecordNotDestroyed => e
      e.message
    end
  end
end
