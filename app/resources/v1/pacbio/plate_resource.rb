# frozen_string_literal: true

module V1
  module Pacbio
    # Provides a JSON:API representation of {Plate}.
    #
    ## Filters:
    # * barcode - Filter plates by their barcode.
    #
    ## Primary relationships:
    # * wells - The wells associated with this plate.
    #
    # @note Access this resource via the `/v1/pacbio/plates/` endpoint.
    #
    # @example
    #   curl -X GET http://localhost:3100/v1/pacbio/plates
    #   curl -X GET http://localhost:3100/v1/pacbio/plates?filter[barcode]=GEN-1762592703-5
    #
    # curl -X POST http://localhost:3100/v1/pacbio/plates \
    #   -H "Content-Type: application/vnd.api+json" \
    #   -H "Accept: application/vnd.api+json" \
    #   -d '{
    #     "data": {
    #       "type": "plates",
    #       "attributes": {
    #         "barcode": "GEN-1762592703-5"
    #       }
    #     }
    #   }'
    #
    class PlateResource < JSONAPI::Resource
      model_name '::Plate'

      # @!attribute [rw] barcode
      #   @return [String] the barcode of the plate
      attribute :barcode

      # @!attribute [r] created_at
      #   @return [String] the creation time of the plate
      attribute :created_at, readonly: true

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
