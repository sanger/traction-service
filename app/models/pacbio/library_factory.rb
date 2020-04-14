# frozen_string_literal: true

# Pacbio namespace
module Pacbio
  # LibraryFactory
  # A library factory can create multiple libraries
  # Each of those libraries can contain one or more requests
  # Each request within that library must contain a tag

  # We can't create request libraries unless the library exists
  # for each set of library attributes:
  # * create a library
  # * if the library is valid. For each request in that library:
  #   create a request library for each request i.e. create a request
  #   library link with an associated tag
  class LibraryFactory
    include ActiveModel::Model
    
    validate :validate_library

    def initialize(libraries_attributes)
      library_attributes = libraries_attributes[0] # TODO singular
      build_library(library_attributes)
    end

    # A LibraryFactory::Library
    def library
      @library
    end

    def save
      return false unless valid?
      library.save
    end

    private

    def build_library(library_attributes)
      @library = Library.new(library_attributes)
    end

    def validate_library
      return if library.valid?

      library.errors.each do |k, v|
        errors.add(k, v)
      end
    end


    # LibraryFactory::Library
    class Library
      include ActiveModel::Model
      
      # validate :check_libraries, :check_tags, :check_cost_codes
      validate :validate_library

      # Pacbio::Library
      attr_reader :library
      
      def initialize(library_attributes)
        build_library(library_attributes)
      end

      def id
        library.id
      end

      # WellFactory::Library::RequestLibraries
      def request_libraries
        @request_libraries ||= []
      end

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

      def save
        return false unless valid?

        library.save
        return false unless request_libraries.save

        true
      end

      def validate_library
      end

      def check_tags
        libraries.each do |library|
          next if library.request_libraries.length < 2

          # here check no two tags in one library are the same
          # libraries[0].request_libraries.map(&:tag).map(&:id).length != 
          # libraries[0].request_libraries.map(&:tag).map(&:id).uniq.length

          if library.request_libraries.any? { |rl| rl.tag_id.nil? }
            errors.add('tag', 'must be present')
          end
        end
      end

      def check_cost_codes
        libraries.each do |library|
          library.request_libraries.each do |rl|
            id = rl.pacbio_request_id
            errors.add('cost code', 'must be present') if Pacbio::Request.find(id).cost_code.empty?
          end
        end
      end

      # LibraryFactory::Library::RequestLibraries
      class RequestLibraries
        include ActiveModel::Model

        validate :validate_request_libraries
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
          return false unless valid?

          library.request_libraries << request_libraries
        end

        private

        def build_request_libraries(requests_attributes)
          requests_attributes.map do |request_attributes|
            request_id = request_attributes[:id]
            tag_id = request_attributes[:tag][:id]
            request_libraries << Pacbio::RequestLibrary.new(pacbio_request_id: request_id, tag_id: tag_id)
          end
          requests_attributes
        end

        # Add a check for request_libraries
        # which loops through each libraries request_libraries
        # checking no two request_libraries
        # have the same pacbio_request_id and pacbio_library_id
        # However, this is what the request_libraries validation does
        # so why doesnt the validation pick it up?
        def validate_request_libraries
        end
        
      end

    end

  end
end
