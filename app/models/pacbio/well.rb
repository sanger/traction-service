# frozen_string_literal: true

module Pacbio
  # Pacbio::Well
  class Well < ApplicationRecord
    belongs_to :plate, class_name: 'Pacbio::Plate', foreign_key: :pacbio_plate_id,
                       inverse_of: :wells
    has_one :library, class_name: 'Pacbio::Library', foreign_key: :pacbio_well_id,
                      inverse_of: :well, dependent: :nullify

    validates :movie_time, :insert_size, :on_plate_loading_concentration,
              :row, :column, presence: true
    validates :movie_time,
              numericality: { greater_than_or_equal_to: 0.1, less_than_or_equal_to: 30 }
    validates :insert_size, numericality: { greater_than_or_equal_to: 10 }

    def position
      "#{row}#{column}"
    end

    def summary
      "#{library.sample.name},#{comment}"
    end
  end
end
