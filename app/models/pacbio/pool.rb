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

    def library_attributes=(library_options)
      self.libraries = library_options.map do |attributes|
        if attributes['id']
          update_library(attributes)
        else
          Pacbio::Library.new(attributes)
        end
      end
    end

    validates :primary_aliquot, presence: true
    accepts_nested_attributes_for :primary_aliquot
    accepts_nested_attributes_for :used_aliquots, allow_destroy: true

    before_save :sync_libraries_and_used_aliquots

    # @return [Array] of Plates attached to a sequencing run
    def sequencing_plates
      wells&.collect(&:plate)
    end

    # @return [Array] of Runs that the pool is used in
    def sequencing_runs
      wells&.collect(&:run)&.uniq
    end

    private

    def sync_libraries_and_used_aliquots
      # Prioritize libraries in the case both are changed
      if libraries.any?(&:changed?)
        libraries.each do |library|
          # If its a new library it will need a new used aliquot
          if library.id.nil?
            used_aliquots << Aliquot.new(
              library.attributes.slice('volume', 'concentration', 'library_kit_box_barcode',
                                       'insert_size', 'tag_id').merge(source: library.request)
            )
          # We want to check the library being updated has a corresponding used aliquot
          elsif used_aliquots.find_by(source_id: library.request.id).present?
            used_aliquots.find_by(source_id: library.request.id).update(library.attributes.slice(
                                                                          'volume', 'concentration', 'library_kit_box_barcode', 'insert_size', 'tag_id'
                                                                        ))
          # The library and used aliquot are out of sync
          else
            errors.add(:used_aliquots,
                       'Unable to sync aliquots and libraries. Please contact support.')
          end
        end
      elsif used_aliquots.any?(&:changed?)
        used_aliquots.each do |aliquot|
          # If its a new used aliquot it will need a new library
          if aliquot.id.nil?
            libraries << Pacbio::Library.new(
              aliquot.attributes.slice('volume', 'concentration', 'library_kit_box_barcode',
                                       'insert_size', 'tag_id').merge(request: aliquot.source)
            )
          # We want to check the used aliquot being updated has a corresponding library
          elsif libraries.find_by(pacbio_request_id: aliquot.source_id).present?
            libraries.find_by(pacbio_request_id: aliquot.source_id).update(aliquot.attributes.slice(
                                                                             'volume', 'concentration', 'library_kit_box_barcode', 'insert_size', 'tag_id'
                                                                           ))
          # The library and used aliquot are out of sync
          else
            errors.add(:libraries, 'Unable to sync aliquots and libraries. Please contact support.')
          end
        end
      end
    end

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
