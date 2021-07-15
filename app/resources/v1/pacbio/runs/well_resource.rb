# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      # WellResource
      class WellResource < JSONAPI::Resource
        model_name 'Pacbio::Well'

        attributes :movie_time, :insert_size, :on_plate_loading_concentration,
                   :row, :column, :pacbio_plate_id, :comment, :generate_hifi,
                   :position, :pre_extension_time, :ccs_analysis_output

        has_many :pools, class_name: 'WellPool', relation_name: :well_pools
      end
    end
  end
end
