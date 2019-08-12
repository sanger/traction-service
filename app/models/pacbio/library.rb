# frozen_string_literal: true

module Pacbio
  # Pacbio::Library
  # A Pacbio Library is capable of being multiplexed i.e.
  # is capable of containing several samples in the form of requests.
  # A library can have many requests but can also belong to many requests
  # A library can be sequenced in more than one well.
  # This is achieved using a has many through relationship
  class Library < ApplicationRecord
    include Material
    include Uuidable

    validates :volume, :concentration, :library_kit_barcode, :fragment_size, presence: true

    has_many :well_libraries, class_name: 'Pacbio::WellLibrary', foreign_key: :pacbio_library_id,
                              dependent: :nullify, inverse_of: :library
    has_many :wells, class_name: 'Pacbio::Well', through: :well_libraries
    has_many :request_libraries, class_name: 'Pacbio::RequestLibrary',
                                 foreign_key: :pacbio_library_id, dependent: :nullify,
                                 inverse_of: :library, autosave: true

    has_many :requests, class_name: 'Pacbio::Request', through: :request_libraries
  end
end
