# frozen_string_literal: true

module V1
  module Ont
    # Provides a JSON:API representation of {Plate}.
    #
    ## Filters:
    # * barcode - Filter plates by their barcode.
    #
    ## Primary relationships:
    # * wells {V1::Ont::WellResource} - The wells contained in the plate.
    #
    # @note Access this resource via the `/v1/ont/plates/` endpoint.
    #
    # @example
    #   curl -X GET http://localhost:3100/v1/ont/plates
    #   curl -X GET http://localhost:3100/v1/ont/plates?include=wells
    #   curl -X GET "http://localhost:3100/v1/ont/plates?filter[barcode]=GEN-1762592713-1&include=wells.requests"
    #   curl -X GET "http://localhost:3100/v1/ont/plates?filter[barcode]=GEN-1762592713-1,GEN-1762592713-2"
    #
    class PlateResource < JSONAPI::Resource
      model_name '::Plate'
      # @!attribute [r] barcode
      #   @return [String] the barcode of the plate
      # @!attribute [r] created_at
      #   @return [String] the creation timestamp of the plate
      attributes :barcode, :created_at

      has_many :wells

      # Filters
      filter :barcode, apply: lambda { |records, value, _options|
        records.by_barcode(value.map { |bc| bc.strip.upcase })
      }

      def self.records(_options = {})
        super.by_pipeline(:ont)
      end

      def created_at
        @model.created_at.to_fs(:us)
      end
    end
  end
end
