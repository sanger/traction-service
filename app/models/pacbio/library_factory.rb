# frozen_string_literal: true

# Pacbio namespace
module Pacbio
  # LibraryFactory
  # A library factory can create multiple libraries
  # Each of those libraries can contain one or more requests
  # Each request within that library must contain a tag
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
    # for each set of library attributes:
    # * create a library
    # * if the library is valid. For each request in that library:
    #   create a request library for each request i.e. create a request
    #   library link with an associated tag
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
