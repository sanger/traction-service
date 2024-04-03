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
    # Delegation required for sample sheets and warehouse messaging when both library and request
    # are used interchangeably
    delegate :sample_name, :cost_code, :external_study_id, :library_type, to: :request
    belongs_to :tag, optional: true
    belongs_to :tube, default: -> { Tube.new }

    has_one :sample, through: :request
    has_one :tag_set, through: :tag

    # # This is dependent on the request and material associations, so needs to be included
    # # after that is defined
    include DualSourcedLibrary

    has_one :source_plate, through: :source_well, source: :plate, class_name: '::Plate'

    validates :primary_aliquot, presence: true
    accepts_nested_attributes_for :primary_aliquot

    after_create :create_used_aliquot
    before_destroy :check_for_derived_aliquots, prepend: true

    def create_used_aliquot
      return if used_aliquots.any?

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

    def collection?
      false
    end

    # Note - This does not take into account when a library is used in a pool
    # and that pool is used in a run
    # @return [Array] of Runs that the pool is used in
    def sequencing_runs
      wells&.collect(&:run)&.uniq
    end

    # Note - This does not take into account when a library is used in a pool
    # and that pool is used in a run
    # @return [Array] of Plates attached to a sequencing run
    def sequencing_plates
      wells&.collect(&:plate)
    end

    private

    # Derived aliquots indicate it has been used in a pool or run
    def check_for_derived_aliquots
      return true if derived_aliquots.empty?

      errors.add(:base, 'Cannot delete a library that is used in a pool or run')
      throw(:abort)
    end
  end
end
