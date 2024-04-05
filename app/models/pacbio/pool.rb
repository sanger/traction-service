# frozen_string_literal: true

# ALIQUOT-CLEANUP
# - Remove the presence validation on libraries
# - Remove the library_attributes= method and the library/used_aliquot sync behaviour
# - Remove the used_aliquots_attributes= method
# - Remove private methods referencing libraries

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

    # We explicitly declare some of the polymorphic relationships to get around json api
    # polymorphism issues so they can retrieved correctly in the client
    has_many :used_aliquot_requests, through: :used_aliquots,
                                     source: :source, source_type: 'Pacbio::Request'
    has_many :used_aliquot_libraries, through: :used_aliquots,
                                      source: :source, source_type: 'Pacbio::Library'

    # This is dependent on the requests association, so needs to be included
    # after that is defined
    include DualSourcedPool

    validates_with TagValidator

    validates :volume, :concentration,
              :insert_size, :template_prep_kit_box_barcode, presence: true, on: :run_creation
    validates :volume, :concentration,
              :insert_size, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

    # We check that both libraries and used_aliquots are present during the transition to aliquots
    # so we can feature flag aliquot introduction and not break any data
    validates :libraries, presence: true
    validates :used_aliquots, presence: true

    # List of common attributes between libraries and used aliquots
    COMMON_ATTRIBUTES = %w[volume concentration insert_size
                           template_prep_kit_box_barcode tag_id].freeze

    # Temporarily disables cops as this will be removed in the future
    # rubocop:disable Metrics/MethodLength
    def library_attributes=(library_options)
      self.libraries = library_options.map do |attributes|
        if attributes['id']
          aliquot = used_aliquots.find_by(source_id: attributes['pacbio_request_id'])
          update_item(attributes.slice(*COMMON_ATTRIBUTES).merge('id' => aliquot&.id),
                      indexed_used_aliquots, 'Aliquot')
          update_item(attributes, indexed_libraries, 'Library')
        else
          used_aliquots.build(attributes.slice(*COMMON_ATTRIBUTES)
            .merge(source_id: attributes['pacbio_request_id'], source_type: 'Pacbio::Request'))
          Pacbio::Library.new(attributes)
        end
      end
      destroy_unused(used_aliquots, 'source_id')
    end

    def used_aliquots_attributes=(used_aliquot_options)
      self.used_aliquots = used_aliquot_options.map do |attributes|
        if attributes['id']
          library = libraries.find_by(pacbio_request_id: attributes['source_id'])
          update_item(attributes.slice(*COMMON_ATTRIBUTES).merge('id' => library&.id),
                      indexed_libraries, 'Library')
          update_item(attributes, indexed_used_aliquots, 'Aliquot')
        else
          libraries.build(attributes.slice(*COMMON_ATTRIBUTES)
                                    .merge(pacbio_request_id: attributes['source_id']))
          Aliquot.new(attributes.merge(aliquot_type: :derived))
        end
      end
      destroy_unused(libraries, 'pacbio_request_id')
    end
    # rubocop:enable Metrics/MethodLength

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

    def collection?
      used_aliquots.length > 1
    end

    private

    # Destroys unused libraries or used_aliquots to keep the pool in sync
    def destroy_unused(collection, exclude_key)
      collection.filter do |item|
        if collection == libraries
          used_aliquots.collect(&:source_id).exclude?(item.send(exclude_key))
        else
          libraries.collect(&:pacbio_request_id).exclude?(item.send(exclude_key))
        end
      end.each(&:destroy)
    end

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

    def indexed_libraries
      @indexed_libraries ||= libraries.index_by { |lib| lib.id.to_s }
    end

    def indexed_used_aliquots
      @indexed_used_aliquots ||= used_aliquots.index_by { |aliquot| aliquot.id.to_s }
    end
  end
end
