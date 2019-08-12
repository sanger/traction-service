# frozen_string_literal: true

# Pacbio namespace
module Pacbio
  # LibraryFactory
  class LibraryFactory
    include ActiveModel::Model

    validate :check_libraries

    def initialize(attributes = [])
      build_libraries(attributes)
    end

    def libraries
      @libraries ||= []
    end

    def save
      return false unless valid?

      libraries.collect(&:save)
      true
    end

    private

    # TODO: is there a better way to do this.
    # We can't create request libraries unless the library exists
    def build_libraries(libraries_attributes)
      libraries_attributes.each do |library_attributes|
        request_attributes = library_attributes.delete(:requests)
        library = Pacbio::Library.create(library_attributes.merge!(tube: Tube.new))
        if library.persisted?
          request_attributes&.each do |request_attribute|
            library.request_libraries.build(pacbio_request_id: request_attribute[:id], tag_id:
              request_attribute[:tag].try(:[], :id))
          end
        end
        libraries << library
      end
    end

    def check_libraries
      if libraries.empty?
        errors.add('libraries', 'there were no libraries')
        return
      end

      libraries.each do |library|
        next if library.valid?

        library.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end
  end
end
