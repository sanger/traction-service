# frozen_string_literal: true

# Pacbio namespace
module Pacbio
  # LibraryFactory
  # A library factory can create one library
  # A library can contain one request

  # For a set of library attributes:
  # * build a library associated with the request
  # * validate the library
  # * save the library
  class LibraryFactory
    include ActiveModel::Model

    validate :validate_library
    validates :cost_code, presence: true

    # Pacbio::Library
    attr_reader :library

    def initialize(library_attributes)
      @library = create_library(library_attributes)
      @container_material = ContainerMaterial.new(container: Tube.new, material: library)
    end

    delegate :id, :request, to: :library
    delegate :cost_code, to: :request

    def save
      # Validate the Pacbio::Library
      return false unless valid?

      library.save && @container_material.save
    end

    private

    def create_library(library_attributes)
      # NOTE: Temporary placeholder fix for backwards compatibility.
      if library_attributes[:requests]
        library_attributes_without_requests = library_attributes.except(:requests)
        extracted_attributes = {
          pacbio_request_id: library_attributes.dig(:requests, 0, :id),
          tag_id: library_attributes.dig(:requests, 0, :tag, :id)
        }
        Pacbio::Library.new(library_attributes_without_requests.merge(extracted_attributes))
      else
        Pacbio::Library.new(library_attributes)
      end
    end

    def validate_library
      return if library.valid?

      library.errors.each do |k, v|
        errors.add(k, v)
      end
    end
  end
end
