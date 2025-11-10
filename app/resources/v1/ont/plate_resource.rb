# frozen_string_literal: true

module V1
  module Ont
    # rubocop:disable Layout/LineLength
    # Provides a JSON:API representation of {Plate} model.
    #
    # Plates are plastic labware containing {Well}s to hold samples.
    #
    # Primary relationships:
    # * wells {V1::Ont::WellResource} - The wells contained in the plate.
    #
    # @note This resource supports only `GET` requests for listing and filtering plates by barcodes.
    # @note Access this resource via the `/v1/ont/plates/` endpoint.
    #
    # @example GET request to list all ONT plates
    #  curl -X GET http://localhost:3100/v1/ont/plates
    #
    # @example GET request to filter ONT plates by two barcodes
    #   curl -X GET "http://localhost:3100/v1/ont/plates" --data-urlencode "filter[barcode]=GEN-1762592713-1,GEN-1762592713-2"
    #   curl -X GET "http://localhost:3100/v1/ont/plates?filter%5Bbarcode%5D=GEN-1762592713-1,GEN-1762592713-2"
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    # rubocop:enable Layout/LineLength
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
