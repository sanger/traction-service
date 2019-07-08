# frozen_string_literal: true

module Pacbio
  # Pacbio::Well
  class Well < ApplicationRecord
    enum sequencing_mode: %w[CLR CCS]

    belongs_to :plate, class_name: 'Pacbio::Plate', foreign_key: :pacbio_plate_id,
                       inverse_of: :wells

    belongs_to :library, foreign_key: :pacbio_library_id, optional: true, inverse_of: :wells

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
      "#{library.sample.name},#{comment}"
    end
  end
end
