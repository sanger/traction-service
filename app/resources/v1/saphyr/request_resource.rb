# frozen_string_literal: true

module V1
  module Saphyr
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/saphyr/request/` endpoint.
    #
    # Provides a JSON:API representation of {Saphyr::Request}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class RequestResource < JSONAPI::Resource
      model_name 'Saphyr::Request', add_model_hint: false

      # @!attribute [rw] external_study_id
      #   @return [String] the external study ID
      # @!attribute [rw] sample_name
      #   @return [String] the name of the sample
      # @!attribute [rw] barcode
      #   @return [String] the barcode of the tube
      # @!attribute [rw] sample_species
      #   @return [String] the species of the sample
      # @!attribute [rw] created_at
      #   @return [String] the creation timestamp of the request
      # @!attribute [rw] source_identifier
      #   @return [String] the source identifier of the request
      attributes(*::Saphyr.request_attributes, :sample_name, :barcode,
                 :sample_species, :created_at, :source_identifier)

      def barcode
        @model&.tube&.barcode
      end

      def created_at
        @model.created_at.to_fs(:us)
      end
    end
  end
end
