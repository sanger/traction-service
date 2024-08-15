# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      # @todo This documentation does not yet include a detailed description of what this resource represents.
      # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
      # @todo This documentation does not yet include any example usage of the API via cURL or similar.
      #
      # @note Access this resource via the `/v1/pacbio/runs/plates` endpoint.
      #
      # Provides a JSON:API representation of {Pacbio::Plate}.
      #
      # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
      # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
      # for the service implementation of the JSON:API standard.
      class PlateResource < JSONAPI::Resource
        model_name 'Pacbio::Plate'

        # @!attribute [rw] pacbio_run_id
        #   @return [Integer] the ID of the Pacbio run
        # @!attribute [rw] plate_number
        #   @return [Integer] the number of the plate
        # @!attribute [rw] sequencing_kit_box_barcode
        #   @return [String] the barcode of the sequencing kit box
        attributes :pacbio_run_id, :plate_number, :sequencing_kit_box_barcode

        has_many :wells, class_name: 'Well'
      end
    end
  end
end
