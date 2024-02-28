# frozen_string_literal: true

module Pacbio
  # Pool
  class Pool < ApplicationRecord
    include Aliquotable
    belongs_to :tube, default: -> { Tube.new }
    has_many :libraries, class_name: 'Pacbio::Library', foreign_key: :pacbio_pool_id,
                         dependent: :destroy, inverse_of: :pool
    has_many :well_pools, class_name: 'Pacbio::WellPool', foreign_key: :pacbio_pool_id,
                          dependent: :nullify, inverse_of: :pool
    has_many :wells, class_name: 'Pacbio::Well', through: :well_pools
    has_many :requests, through: :libraries

    # This is dependent on the requests association, so needs to be included
    # after that is defined
    include DualSourcedPool

    validates_with TagValidator

    validates :volume, :concentration,
              :insert_size, :template_prep_kit_box_barcode, presence: true, on: :run_creation
    validates :volume, :concentration,
              :insert_size, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
    validates :libraries, presence: true

    COMMON_LIBRARY_ATTRIBUTES = %w[volume concentration insert_size
                                   template_prep_kit_box_barcode tag_id].freeze

    def library_attributes=(library_options)
      self.libraries = library_options.map do |attributes|
        if attributes['id']
          aliquot = used_aliquots.find_by(source_id: attributes['pacbio_request_id'])
          update_used_aliquot(attributes.slice(COMMON_LIBRARY_ATTRIBUTES).merge('id' => aliquot.id))
          update_library(attributes)
        else
          used_aliquots.build(attributes.slice(COMMON_LIBRARY_ATTRIBUTES)
            .merge(source_id: attributes['pacbio_request_id'], source_type: 'Pacbio::Request'))
          Pacbio::Library.new(attributes)
        end
      end
      destroy_unused_aliquots
    end

    def used_aliquots_attributes=(used_aliquot_options)
      self.used_aliquots = used_aliquot_options.map do |attributes|
        if attributes['id']
          library = libraries.find_by(pacbio_request_id: attributes['source_id'])
          update_library(attributes.slice(COMMON_LIBRARY_ATTRIBUTES).merge('id' => library.id))
          update_used_aliquot(attributes)
        else
          libraries.build(attributes.slice(COMMON_LIBRARY_ATTRIBUTES)
                                    .merge(pacbio_request_id: attributes['source_id']))
          Aliquot.new(attributes)
        end
      end
      destroy_unused_libraries
    end

    validates :primary_aliquot, presence: true
    accepts_nested_attributes_for :primary_aliquot

    # @return [Array] of Plates attached to a sequencing run
    def sequencing_plates
      wells&.collect(&:plate)
    end

    # @return [Array] of Runs that the pool is used in
    def sequencing_runs
      wells&.collect(&:run)&.uniq
    end

    private

    def destroy_unused_libraries
      libraries.filter do |lib|
        used_aliquots.pluck(:source_id).exclude?(lib.pacbio_request_id)
      end.each(&:destroy)
    end

    def destroy_unused_aliquots
      used_aliquots.filter do |aliquot|
        libraries.pluck(:pacbio_request_id).exclude?(aliquot.source_id)
      end.each(&:destroy)
    end

    def update_library(attributes)
      id = attributes['id'].to_s
      indexed_libraries.fetch(id) { missing_library(id) }
                       .tap { |l| l.update(attributes) }
    end

    def update_used_aliquot(attributes)
      id = attributes['id'].to_s
      indexed_used_aliquots.fetch(id) { missing_used_aliquot(id) }
                           .tap { |a| a.update(attributes) }
    end

    def missing_library(id)
      raise ActiveRecord::RecordNotFound, "Pacbio library #{id} is not part of the pool"
    end

    def missing_used_aliquot(id)
      raise ActiveRecord::RecordNotFound, "Aliquot #{id} is not part of the pool"
    end

    def indexed_libraries
      @indexed_libraries ||= libraries.index_by { |lib| lib.id.to_s }
    end

    def indexed_used_aliquots
      @indexed_used_aliquots ||= used_aliquots.index_by { |aliquot| aliquot.id.to_s }
    end
  end
end
