# frozen_string_literal: true

module Pacbio
  # Pacbio::Library
  # A Pacbio Library is capable of being multiplexed i.e.
  # is capable of containing several samples in the form of requests.
  # A library can have many requests but can also belong to many requests
  # A library can be sequenced in more than one well.
  # This is achieved using a has many through relationship
  class Library < ApplicationRecord
    include TubeMaterial
    include Uuidable
    include Librarian

    validates :volume, :concentration, :template_prep_kit_box_barcode,
              :fragment_size, presence: true

    has_many :well_libraries, class_name: 'Pacbio::WellLibrary', foreign_key: :pacbio_library_id,
                              dependent: :nullify, inverse_of: :library
    has_many :wells, class_name: 'Pacbio::Well', through: :well_libraries
    has_many :request_libraries, class_name: 'Pacbio::RequestLibrary',
                                 foreign_key: :pacbio_library_id, dependent: :destroy,
                                 inverse_of: :library, autosave: true

    has_many :requests, class_name: 'Pacbio::Request', through: :request_libraries

    # This is dependent on the requests association, so needs to be included
    # after that is defined
    include PlateSourcedLibrary

    delegate :barcode, to: :tube, allow_nil: true

    belongs_to :request, class_name: 'Pacbio::Request', foreign_key: :pacbio_request_id, optional: true
    belongs_to :tag, optional: true
    belongs_to :pool, class_name: 'Pacbio::Pool', foreign_key: :pacbio_pool_id, optional: true

    def sample_names
      return '' if requests.blank?

      requests.collect(&:sample_name).join(',')
    end
  end
end
