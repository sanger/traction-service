# frozen_string_literal: true

# Pacbio namespace
module Pacbio
  # LibraryFactory
  # A library factory can create one library
  # A library can contain one or more requests

  # When there is more than one request
  # Each request within that library must contain a tag
  # And each tag must be unique

  # We can't create request libraries unless the library exists
  # For a set of library attributes:
  # * build a library
  # * build the request libraries
  # * validate the library
  # * validate the request libraries
  # * save the library
  # * save the request libraries
  # * associate request libraries with the library
  class LibraryFactory
    include ActiveModel::Model

    validate :validate_library_and_request_libraries

    # Pacbio::Library
    attr_reader :library

    def initialize(libraries_attributes)
      library_attributes = libraries_attributes[0] # TODO singular
      build_library(library_attributes)
    end

    def id
      library.id
    end

    # WellFactory::RequestLibraries
    def request_libraries
      @request_libraries ||= []
    end

    def save
      # Validate the Pacbio::Library and its Pacbio::RequestLibrary(s)
      return false unless valid?

      begin
        library.save!
        raise 'Failed' unless request_libraries.save
      rescue => exception
        library.destroy
        errors.add('Failed to create library', exception)
        return false
      end
      true
    end

    private

    def build_library(library_attributes)
      @library = create_library(library_attributes)
      request_attributes = library_attributes[:requests]
      build_request_libraries(request_attributes)
    end

    def create_library(library_attributes)
      library_attributes_without_requests = library_attributes.except(:requests)
      Pacbio::Library.new(library_attributes_without_requests.merge!(tube: Tube.new))
    end
    
    def build_request_libraries(requests_attributes)
      @request_libraries = RequestLibraries.new(library, requests_attributes)
    end

    def validate_library_and_request_libraries
      unless library.valid?
        library.errors.each do |k, v|
          errors.add(k, v)
        end
      end

      return if request_libraries.valid?

      request_libraries.errors.each do |k, v|
        errors.add(k, v)
      end
    end

    # LibraryFactory::RequestLibraries
    class RequestLibraries
      include ActiveModel::Model

      validate :check_tags, :check_cost_codes, :check_requests_uniq

      attr_reader :library

      def initialize(library, requests_attributes)
        @library = library
        build_request_libraries(requests_attributes)
      end

      # Pacbio::RequestLibrary
      def request_libraries
        @request_libraries ||= []
      end

      def save
        library.request_libraries << request_libraries
      end

      private

      def build_request_libraries(requests_attributes)
        requests_attributes.map do |request_attributes|
          request_id = request_attributes[:id]
          tag_id = request_attributes[:tag].try(:[], :id)
          request_libraries << Pacbio::RequestLibrary.new(pacbio_request_id: request_id, tag_id: tag_id)
        end
      end

      def check_tags
        return true if request_libraries.length < 2

        if request_libraries.any? { |rl| rl.tag_id.nil? }
          errors.add('tag', 'must be present')
          return
        end
  
        # Check no two tags in one library are the same
        tag_ids = request_libraries.map(&:tag_id)
        if tag_ids.length != tag_ids.uniq.length
          errors.add('tag', 'is used more than once')
        end
      end

      def check_cost_codes
        request_libraries.each do |rl|
          id = rl.pacbio_request_id
          errors.add('cost code', 'must be present') if Pacbio::Request.find(id).cost_code.empty?
        end
      end

      # Check no two requests in one library are the same
      def check_requests_uniq
        request_ids = request_libraries.map(&:pacbio_request_id)
        if request_ids.length != request_ids.uniq.length
          errors.add('request', 'is used more than once')
        end
      end

    end
  end
end
