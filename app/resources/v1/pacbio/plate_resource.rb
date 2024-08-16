# frozen_string_literal: true

module V1
  module Pacbio
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/pacbio/plates/` endpoint.
    #
    # Provides a JSON:API representation of {Plate}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class PlateResource < JSONAPI::Resource
      model_name '::Plate'

      # @!attribute [rw] barcode
      #   @return [String] the barcode of the plate
      # @!attribute [rw] created_at
      #   @return [String] the creation time of the plate
      attributes :barcode, :created_at

      has_many :wells

      paginator :paged

      def self.default_sort
        [{ field: 'created_at', direction: :desc }]
      end

      filter :barcode

      def self.records(_options = {})
        super.by_pipeline(:pacbio)
      end

      def created_at
        @model.created_at.to_fs(:us)
      end
    end
  end
end
