# frozen_string_literal: true

module Pacbio
  # Pacbio::Well
  # A well can have many libraries
  class Well < ApplicationRecord
    GENERIC_KIT_BARCODE = 'Lxxxxx100938900123199'

    include Uuidable
    include SampleSheet::Well
    include Aliquotable

    belongs_to :plate, class_name: 'Pacbio::Plate', foreign_key: :pacbio_plate_id,
                       inverse_of: :wells
    has_many :pools, class_name: 'Pacbio::Pool', through: :used_aliquots,
                     source: :source, source_type: 'Pacbio::Pool'
    has_many :libraries, class_name: 'Pacbio::Library', through: :used_aliquots,
                         source: :source, source_type: 'Pacbio::Library'

    validates :used_aliquots, presence: true

    # pacbio smrt link options for a well are kept in store field of the well
    # which is mapped to smrt_link_options column (JSON) of pacbio_wells table.
    # They are accessible on the model as well.
    # See https://api.rubyonrails.org/classes/ActiveRecord/Store.html
    # We now get the accessors from configuration
    store :smrt_link_options

    # using store_accessor allows you to lazy load the accessors
    store_accessor :smrt_link_options, Rails.configuration.pacbio_smrt_link_versions.options.keys

    # The SmrtLinkOptions validator gives full details on how this works
    # validations are loaded from the database
    # See SMRT link versions and SMRT link options for further
    # explanation
    validates_with SmrtLinkOptionsValidator

    validates_with WellValidator

    validates :row, :column, presence: true

    validate :used_aliquots_volume

    delegate :run, to: :plate, allow_nil: true

    accepts_nested_attributes_for :used_aliquots, allow_destroy: true

    def tag_set
      base_used_aliquots.collect(&:tag_set).first
    end

    def sample_sheet_behaviour
      SampleSheetBehaviour.get(tag_set&.sample_sheet_behaviour || :untagged)
    end

    def position
      "#{row}#{column}"
    end

    def summary
      "#{sample_names} #{comment}".strip
    end

    # A collection of all the used_aliquots for given libraries and pools in a well
    def base_used_aliquots
      used_aliquots.reject(&:marked_for_destruction?)
                   .collect(&:source).collect(&:used_aliquots).flatten
    end

    # collection of all of the requests for a library
    # useful for messaging
    def request_libraries
      raise StandardError, 'Unsupported, fix this'
    end

    # a collection of all the sample names for a particular well
    # useful for comments
    def sample_names(separator = ':')
      base_used_aliquots.collect(&:source).collect(&:sample_name).join(separator)
    end

    # check if any of the aliquots or libraries in the well are tagged
    # a convenience method for the sample sheet
    def tagged?
      base_used_aliquots.collect(&:tagged?).any?
    end

    # a collection of all the tags for a well
    # useful to check whether they are unique
    def tags
      base_used_aliquots.collect(&:tag_id)
    end

    def pools?
      pools.present?
    end

    def libraries?
      libraries.present?
    end

    def template_prep_kit_box_barcode
      base_used_aliquots.first.used_by.template_prep_kit_box_barcode
    end

    def insert_size
      base_used_aliquots.first.used_by.insert_size
    end

    # Always true for wells, but always false for libraries/aliquots - a gross simplification
    def collection?
      true
    end

    def adaptive_loading_check
      loading_target_p1_plus_p2.present?
    end

    # This method is used to update the smrt_link_options for a well
    # It takes a hash of options and updates the smrt_link_options store field
    # with the new values
    # we do a save! at the end to ensure that the changes are persisted
    # it is better to update the smrt link options in the well as it uses a private method
    # @param options [Hash] a hash of options to update
    def update_smrt_link_options(options)
      options.each do |key, value|
        write_store_attribute(:smrt_link_options, key, value)
      end
      save!
    end
  end
end
