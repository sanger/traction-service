# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      # PlateResource
      class PlateResource < JSONAPI::Resource
        model_name 'Pacbio::Plate'

        attributes :pacbio_run_id, :plate_number, :sequencing_kit_box_barcode

        has_many :wells, class_name: 'Well'
      end
    end
  end
end
