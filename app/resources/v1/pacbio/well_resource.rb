# frozen_string_literal: true

module V1
  module Pacbio
    # WellResource
    class WellResource < JSONAPI::Resource
      model_name 'Pacbio::Well'

      attributes :movie_time, :insert_size, :on_plate_loading_concentration,
                 :row, :column, :pacbio_plate_id, :comment, :sequencing_mode,
                 :position, :pre_extension_time

      has_many :libraries, class_name: 'WellLibrary'
    end
  end
end
