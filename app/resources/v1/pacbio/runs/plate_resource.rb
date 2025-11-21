# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      #
      # @note This endpoint can't be directly accessed via the `/v1/pacbio/runs/plates/` endpoint
      # as it is only accessible via the nested route under {V1::Pacbio::Run} using includes.
      #
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
