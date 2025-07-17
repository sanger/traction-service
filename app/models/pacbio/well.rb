# frozen_string_literal: true

module Pacbio
  # Pacbio::Well
  # A well can have many libraries
  class Well < ApplicationRecord
    GENERIC_KIT_BARCODE = 'Lxxxxx100938900123199'

    include Uuidable
    include Aliquotable

    belongs_to :plate, class_name: 'Pacbio::Plate', foreign_key: :pacbio_plate_id,
                       inverse_of: :wells
    has_many :pools, class_name: 'Pacbio::Pool', through: :used_aliquots,
                     source: :source, source_type: 'Pacbio::Pool'
    has_many :libraries, class_name: 'Pacbio::Library', through: :used_aliquots,
                         source: :source, source_type: 'Pacbio::Library'

    # allows creation of annotations
    has_many :annotations, as: :annotatable, dependent: :destroy

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
    accepts_nested_attributes_for :annotations, allow_destroy: true

    attr_reader :annotations_attributes

    # @return [TagSet | NullTagSet] the tag set for the first aliquot or null tag set
    def tag_set
      base_used_aliquots.collect(&:tag_set).first || NullTagSet.new
    end

    def position
      "#{row}#{column}"
    end

    def summary
      sample_names.to_s
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

    # @return [Boolean] true if the well has any pools
    def pools?
      pools.present?
    end

    # @return [Boolean] true if the well has any libraries
    def libraries?
      libraries.present?
    end

    # @return [String] the template_prep_kit_box_barcode of the first aliquot
    def template_prep_kit_box_barcode
      base_used_aliquots.first.used_by.template_prep_kit_box_barcode
    end

    # @return [String] the insert_size of the first used_by aliqout
    def insert_size
      base_used_aliquots.first.used_by.insert_size
    end

    # Always true for wells, but always false for libraries/aliquots - a gross simplification
    def collection?
      true
    end

    # @return [Boolean] true if loading_target_p1_plus_p2 is present
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

    # SAMPLE SHEET GENERATION
    # The following methods are used to generate the sample sheet for the Pacbio::Well

    # Sample Well field
    def position_leading_zero
      "#{row}#{column.rjust(2, '0')}"
    end

    # Sample Plate Well field
    def plate_well_position
      "#{plate.plate_number}_#{position_leading_zero}"
    end

    # Barcode Set field
    def barcode_set
      return if tag_set.hidden_sample_sheet_behaviour?

      tag_set.uuid
    end

    # Determines rendering of a row-per sample
    def show_row_per_sample?
      return false if tag_set.hidden_sample_sheet_behaviour?

      base_used_aliquots.any?(&:tag_id?)
    end

    # Returns libraries only if they should be shown per row
    def aliquots_to_show_per_row
      return unless show_row_per_sample?

      base_used_aliquots
    end

    # Sample Name field
    def tube_barcode
      # Gets the first barcode which will either be the pool barcode or the library barcode
      base_used_aliquots.first.used_by.tube.barcode
    end

    # find the plate given the plate_number
    # returns `nil` if no plate found
    def get_plate(plate_number)
      plate.run.plates.filter { |plate| plate.plate_number == plate_number }.first
    end

    # return the sequencing_kit_box_barcode of plate 1
    # used for 2-plate sample sheets
    def sequencing_kit_box_barcode_plate_1
      get_plate(1)&.sequencing_kit_box_barcode
    end

    # return the sequencing_kit_box_barcode of plate 2
    # used for 2-plate sample sheets
    def sequencing_kit_box_barcode_plate_2
      get_plate(2)&.sequencing_kit_box_barcode
    end

    # # Used to indicate to the sample sheet whether it should treat a sample as barcoded
    # # Note: This doesn't actually indicate that a sample *is* barcoded, as :hidden
    # # tag sets (such as IsoSeq) lie.
    def sample_is_barcoded
      tag_set.default_sample_sheet_behaviour?
    end

    # Are the left and right adapters the same?
    # Returns True if tagged, nil otherwise
    # See Aliquot#adapter field method below and adapter and adapter2 fields in pacbio.yml
    def same_barcodes_on_both_ends_of_sequence
      return nil unless tagged?

      base_used_aliquots.first&.tag&.oligo_reverse.nil?
    end

    # Set the automation parameters
    # @return [String] Returns nil if pre_extension_time is 0 or nil
    # @example  ExtensionTime=double:#5|ExtendFirst=boolean:True
    def automation_parameters
      return if pre_extension_time == 0 || pre_extension_time.nil?

      "ExtensionTime=double:#{pre_extension_time}|ExtendFirst=boolean:True"
    end

    # Sample bio Name field
    # Returns nil if sample is barcoded otherwise returns the sample names for all of the aliquots
    def bio_sample_name
      sample_is_barcoded ? nil : sample_names
    end

    # Returns the formatted bio sample name.
    # If the sample is barcoded, it returns nil.
    # Otherwise, it returns the sample names with colons replaced by hyphens.
    def formatted_bio_sample_name
      bio_sample_name&.gsub(':', '-')
    end
  end
end
