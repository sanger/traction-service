# frozen_string_literal: true

module Pacbio
  # Pacbio::Library
  class Library < ApplicationRecord
    include Material
    include Uuidable

    validates :volume, :concentration, :library_kit_barcode, :fragment_size, presence: true

    has_many :well_libraries, class_name: 'Pacbio::WellLibrary', foreign_key: :pacbio_library_id
    has_many :wells, class_name: 'Pacbio::Well', through: :well_libraries
    has_many :request_libraries, class_name: 'Pacbio::RequestLibrary',
                                 foreign_key: :pacbio_library_id
    has_many :requests, class_name: 'Pacbio::Request', through: :request_libraries
  end
end
