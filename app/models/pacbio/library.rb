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
    include SampleSheet::Library

    validates :volume, :concentration,
              :insert_size, presence: true

    belongs_to :request, class_name: 'Pacbio::Request', foreign_key: :pacbio_request_id,
                         inverse_of: :libraries
    belongs_to :tag, optional: true
    belongs_to :pool, class_name: 'Pacbio::Pool', foreign_key: :pacbio_pool_id,
                      inverse_of: :libraries

    has_one :sample, through: :request
    has_one :tube, through: :pool
    has_one :tag_set, through: :tag

    # # This is dependent on the request association, so needs to be included
    # # after that is defined
    include DualSourcedLibrary

    has_one :source_plate, through: :source_well, source: :plate, class_name: '::Plate'

    def collection?
      false
    end

    def sample_sheet_behaviour
      (tag_set&.sample_sheet_behaviour_class || SampleSheetBehaviour::Untagged).new
    end
  end
end
