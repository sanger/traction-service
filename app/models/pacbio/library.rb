# frozen_string_literal: true

module Pacbio
  # Pacbio::Library
  # A Pacbio Library is capable of being multiplexed i.e.
  # is capable of containing several samples in the form of requests.
  # A library can have many requests but can also belong to many requests
  # A library can be sequenced in more than one well.
  # This is achieved using a has many through relationship
  class Library < ApplicationRecord
    # Material is needed to support source identification
    include Material
    include Uuidable
    include Librarian
    include SampleSheet::Library
    include Aliquotable

    validates :volume, :concentration,
              :insert_size, presence: true, on: :run_creation
    validates :volume, :concentration,
              :insert_size, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

    has_many :well_libraries, class_name: 'Pacbio::WellLibrary', foreign_key: :pacbio_library_id,
                              dependent: :nullify, inverse_of: :library
    has_many :wells, class_name: 'Pacbio::Well', through: :well_libraries

    belongs_to :request, class_name: 'Pacbio::Request', foreign_key: :pacbio_request_id,
                         inverse_of: :libraries
    belongs_to :tag, optional: true
    belongs_to :pool, class_name: 'Pacbio::Pool', foreign_key: :pacbio_pool_id,
                      inverse_of: :libraries, optional: true
    belongs_to :tube, optional: true

    has_one :sample, through: :request
    has_one :tag_set, through: :tag

    # # This is dependent on the request and material associations, so needs to be included
    # # after that is defined
    include DualSourcedLibrary

    has_one :source_plate, through: :source_well, source: :plate, class_name: '::Plate'

    # TODO: remove pool constraint this when pools are updated for aliquots
    validates :primary_aliquot, presence: true, if: -> { pool.blank? }
    accepts_nested_attributes_for :primary_aliquot, allow_destroy: true

    after_create :create_used_aliquot, :create_tube, if: -> { pool.blank? }

    def create_used_aliquot
      used_aliquots.create(
        source: request,
        aliquot_type: :derived,
        volume:,
        concentration:,
        template_prep_kit_box_barcode:,
        insert_size:,
        tag:
      )
    end

    def create_tube
      self.tube = tube || Tube.create!
      save
    end

    def tube
      pool ? pool.tube : super
    end

    def collection?
      false
    end

    def sample_sheet_behaviour
      SampleSheetBehaviour.get(tag_set&.sample_sheet_behaviour || :untagged)
    end

    # @return [Array] of Plates attached to a sequencing run
    def sequencing_plates
      # TODO: remove this when pools are updated for aliquots
      if pool
        pool.sequencing_plates
      else
        wells&.collect(&:plate)
      end
    end
  end
end
