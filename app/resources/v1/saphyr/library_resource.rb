# frozen_string_literal: true

module V1
  module Saphyr
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/api/v1/saphyr/library/` endpoint.
    #
    # Provides a JSON:API representation of {Saphyr::Library}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class LibraryResource < JSONAPI::Resource
      model_name 'Saphyr::Library', add_model_hint: false

      # @!attribute [rw] state
      #   @return [String] the state of the library
      # @!attribute [rw] barcode
      #   @return [String] the barcode of the tube
      # @!attribute [rw] sample_name
      #   @return [String] the name of the sample
      # @!attribute [rw] enzyme_name
      #   @return [String] the name of the enzyme
      # @!attribute [rw] created_at
      #   @return [String] the creation timestamp of the library
      # @!attribute [rw] deactivated_at
      #   @return [String] the deactivation timestamp of the library
      attributes :state, :barcode, :sample_name, :enzyme_name, :created_at, :deactivated_at
      has_one :request, class_name: 'Request'
      has_one :tube

      def barcode
        @model.tube&.barcode
      end

      def sample_name
        @model.request&.sample_name
      end

      def enzyme_name
        @model.enzyme&.name
      end

      def created_at
        @model.created_at.to_fs(:us)
      end

      def deactivated_at
        @model&.deactivated_at&.to_fs(:us)
      end

      def self.records(_options = {})
        ::Saphyr::Library.active
      end
    end
  end
end
