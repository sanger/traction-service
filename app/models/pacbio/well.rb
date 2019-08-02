# frozen_string_literal: true

module Pacbio
  # Pacbio::Well
  class Well < ApplicationRecord
    include Uuidable

    enum sequencing_mode: %w[CLR CCS]

    belongs_to :plate, class_name: 'Pacbio::Plate', foreign_key: :pacbio_plate_id,
                       inverse_of: :wells

    has_many :well_libraries, class_name: 'Pacbio::WellLibrary', foreign_key: :pacbio_well_id,
                              dependent: :nullify, inverse_of: :well
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
      "#{sample_names},#{comment}"
    end

    def generate_ccs_data
      sequencing_mode == 'CCS'
    end

    def request_libraries
      @request_libraries ||= libraries.collect(&:request_libraries).flatten
    end

    def sample_names
      @sample_names ||= request_libraries.collect(&:request).collect(&:sample_name).join(',')
    end
  end
end
