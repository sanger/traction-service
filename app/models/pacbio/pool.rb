# frozen_string_literal: true

module Pacbio
  # Pool
  class Pool < ApplicationRecord
    belongs_to :tube, default: -> { Tube.new }
    has_many :libraries, class_name: 'Pacbio::Library', foreign_key: :pacbio_pool_id,
                         dependent: :destroy, inverse_of: :pool
    has_many :well_pools, class_name: 'Pacbio::WellPool', foreign_key: :pacbio_pool_id,
                          dependent: :nullify, inverse_of: :pool
    has_many :wells, class_name: 'Pacbio::Well', through: :well_pools
    has_many :requests, through: :libraries

    # This is dependent on the requests association, so needs to be included
    # after that is defined
    include PlateSourcedLibrary

    validates :libraries, presence: true
    validates_with TagValidator

    validates :volume, :concentration,
              :insert_size, :template_prep_kit_box_barcode, presence: true, on: :run_creation
    validates :volume, :concentration,
              :insert_size, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

    def library_attributes=(library_options)
      self.libraries = library_options.map do |attributes|
        if attributes['id']
          update_library(attributes)
        else
          Pacbio::Library.new(attributes)
        end
      end
    end

    # @return [Array] of Plates attached to a sequencing run
    def sequencing_plates
      wells&.collect(&:plate)
    end

    private

    def update_library(attributes)
      id = attributes['id'].to_s
      indexed_libraries.fetch(id) { missing_library(id) }
                       .tap { |l| l.update(attributes) }
    end

    def missing_library(id)
      raise ActiveRecord::RecordNotFound, "Pacbio request #{id} is not part of the pool"
    end

    def indexed_libraries
      @indexed_libraries ||= libraries.index_by { |lib| lib.id.to_s }
    end
  end
end
