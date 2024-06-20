# frozen_string_literal: true

module Pacbio
  # Pool
  class Pool < ApplicationRecord
    include Aliquotable
    belongs_to :tube, default: -> { Tube.new }

    has_many :wells, through: :derived_aliquots, source: :used_by, source_type: 'Pacbio::Well'
    has_many :requests, through: :used_aliquots, source: :source, source_type: 'Pacbio::Request'
    has_many :libraries, through: :used_aliquots, source: :source, source_type: 'Pacbio::Library'

    # This is dependent on the requests and libraries associations, so needs to be included
    # after that is defined
    include MultiSourcedPool

    validates_with TagValidator

    validates :volume, :concentration,
              :insert_size, :template_prep_kit_box_barcode, presence: true, on: :run_creation
    validates :volume, :concentration,
              :insert_size, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

    validates :used_aliquots, presence: true
    validates :primary_aliquot, presence: true
    validate :used_aliquots_volume

    accepts_nested_attributes_for :primary_aliquot

    def used_aliquots_volume
      # Get all the aliquots that are libraries and have insufficient volume
      failed_aliquots = used_aliquots.select do |aliquot|
        aliquot.source_type == 'Pacbio::Library' &&
          !aliquot.source.available_volume_sufficient
      end
      # Return if there are no aliquots that failed the volume check
      return if failed_aliquots.empty?

      # If there are failed aliquots we want to collect the source barcodes add an error to the pool
      failed_barcodes = failed_aliquots.map { |aliquot| aliquot.source.tube.barcode }.join(',')
      errors.add(:base, "Insufficient volume available for #{failed_barcodes}")
      false
    end

    def used_aliquots_attributes=(used_aliquot_options)
      self.used_aliquots = used_aliquot_options.map do |attributes|
        if attributes['id']
          update_item(attributes, indexed_used_aliquots, 'Aliquot')
        else
          Aliquot.new(attributes.merge(aliquot_type: :derived))
        end
      end
    end

    # @return [Array] of Plates attached to a sequencing run
    def sequencing_plates
      wells&.collect(&:plate)
    end

    # @return [Array] of Runs that the pool is used in
    def sequencing_runs
      wells&.collect(&:run)&.uniq
    end

    def collection?
      used_aliquots.length > 1
    end

    private

    # Takes a collection of attributes and updates the item if it exists in the collection
    # otherwise raises an error based on the type
    def update_item(attributes, collection, type)
      id = attributes['id'].to_s
      collection.fetch(id) { missing_data(id, type) }
                .tap { |item| item.update(attributes) }
    end

    def missing_data(id, type)
      raise ActiveRecord::RecordNotFound, "#{type} is not part of the pool #{id}"
    end

    def indexed_used_aliquots
      @indexed_used_aliquots ||= used_aliquots.index_by { |aliquot| aliquot.id.to_s }
    end
  end
end
