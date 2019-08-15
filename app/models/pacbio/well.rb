# frozen_string_literal: true

module Pacbio
  # Pacbio::Well
  # A well can have many libraries
  class Well < ApplicationRecord
    include Uuidable

    enum sequencing_mode: { 'CLR' => 0, 'CCS' => 1 }

    belongs_to :plate, class_name: 'Pacbio::Plate', foreign_key: :pacbio_plate_id,
                       inverse_of: :wells

    has_many :well_libraries, class_name: 'Pacbio::WellLibrary', foreign_key: :pacbio_well_id,
                              dependent: :nullify, inverse_of: :well, autosave: true
    has_many :libraries, class_name: 'Pacbio::Library', through: :well_libraries, autosave: true

    validates :movie_time, :insert_size, :on_plate_loading_concentration,
              :row, :column, :sequencing_mode, presence: true
    validates :movie_time,
              numericality: { greater_than_or_equal_to: 0.1, less_than_or_equal_to: 30 }
    validates :insert_size, numericality: { greater_than_or_equal_to: 10 }

    def position
      "#{row}#{column}"
    end

    def summary
      "#{sample_names},#{comment}"
    end

    def generate_ccs_data
      sequencing_mode == 'CCS'
    end

    # collection of all of the requests for a library
    # useful for messaging
    def request_libraries
      libraries.collect(&:request_libraries).flatten
    end

    # a collection of all the sample names for a particular well
    # useful for comments
    def sample_names
      request_libraries.collect(&:request).collect(&:sample_name).join(',')
    end

    # a collection of all the tags for a well
    # useful to check whether they are unique
    def tags
      request_libraries.collect(&:tag_id)
    end
  end
end
