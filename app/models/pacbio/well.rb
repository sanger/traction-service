# frozen_string_literal: true

module Pacbio
  # Pacbio::Well
  class Well < ApplicationRecord
    include Uuidable

    enum sequencing_mode: %w[CLR CCS]

    belongs_to :plate, class_name: 'Pacbio::Plate', foreign_key: :pacbio_plate_id,
                       inverse_of: :wells

    belongs_to :library, foreign_key: :pacbio_library_id, optional: true, inverse_of: :wells

    has_many :well_libraries, class_name: 'Pacbio::WellLibrary', foreign_key: :pacbio_well_id
    has_many :libraries, class_name: 'Pacbio::Library', through: :well_libraries

    validates :movie_time, :insert_size, :on_plate_loading_concentration,
              :row, :column, presence: true
    validates :movie_time,
              numericality: { greater_than_or_equal_to: 0.1, less_than_or_equal_to: 30 }
    validates :insert_size, numericality: { greater_than_or_equal_to: 10 }
    validates :sequencing_mode, presence: true

    def position
      "#{row}#{column}"
    end

    def summary
      "#{library.request.sample_name},#{comment}"
    end

    def generate_ccs_data
      sequencing_mode == 'CCS'
    end

    def request_libraries
      libraries.collect(&:request_libraries).flatten
    end
  end
end
