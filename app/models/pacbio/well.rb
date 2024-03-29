# frozen_string_literal: true

# ALIQUOT-CLEANUP
# - Update references for libraries and pools to be through used_aliquots
# - Update library_ids and pools_ids to only update used_aliquots

module Pacbio
  # Pacbio::Well
  # A well can have many libraries
  class Well < ApplicationRecord # rubocop:disable Metrics/ClassLength
    GENERIC_KIT_BARCODE = 'Lxxxxx100938900123199'

    include Uuidable
    include SampleSheet::Well
    include Aliquotable

    belongs_to :plate, class_name: 'Pacbio::Plate', foreign_key: :pacbio_plate_id,
                       inverse_of: :wells
    has_many :well_pools, class_name: 'Pacbio::WellPool', foreign_key: :pacbio_well_id,
                          dependent: :destroy, inverse_of: :well, autosave: true
    has_many :pools, class_name: 'Pacbio::Pool', through: :well_pools
    has_many :well_libraries, class_name: 'Pacbio::WellLibrary', foreign_key: :pacbio_well_id,
                              dependent: :destroy, inverse_of: :well, autosave: true
    has_many :libraries, class_name: 'Pacbio::Library', through: :well_libraries

    validates :used_aliquots, presence: true, if: -> { Flipper.enabled?(:dpl_1112) }

    # pacbio smrt link options for a well are kept in store field of the well
    # which is mapped to smrt_link_options column (JSON) of pacbio_wells table.
    # They are accessible on the model as well.
    # See https://api.rubyonrails.org/classes/ActiveRecord/Store.html

    store :smrt_link_options,
          accessors: %i[ccs_analysis_output
                        generate_hifi
                        ccs_analysis_output_include_low_quality_reads
                        include_fivemc_calls_in_cpg_motifs
                        ccs_analysis_output_include_kinetics_information
                        demultiplex_barcodes
                        on_plate_loading_concentration
                        binding_kit_box_barcode
                        pre_extension_time
                        loading_target_p1_plus_p2
                        movie_time
                        movie_acquisition_time
                        include_base_kinetics
                        library_concentration
                        polymerase_kit]

    # The SmrtLinkOptions validator gives full details on how this works
    # validations are loaded from the database
    # See SMRT link versions and SMRT link options for further
    # explanation
    validates_with SmrtLinkOptionsValidator

    validates_with WellValidator

    validates :row, :column, presence: true

    delegate :run, to: :plate, allow_nil: true

    def pool_ids=(ids)
      # Don't update the used_aliquots if the feature flag is disabled
      unless Flipper.enabled?(:dpl_1112)
        super
        return
      end

      # Map the ids to integers as they may be strings
      ids.map!(&:to_i).each do |id|
        # If the used_aliquot already exists, skip it
        next if used_aliquots.find_by(source_id: id)

        # Create a new used_aliquot if it doesn't exist
        used_aliquots << used_aliquots.build(source_id: id, source_type: 'Pacbio::Pool',
                                             volume: 0, concentration: 0, aliquot_type: :derived,
                                             template_prep_kit_box_barcode: '033000000000000000000')
      end

      # If the used_aliquot is not in the list of ids, remove it
      destroy_aliquots_by_source_type_and_id(ids, 'Pacbio::Pool')

      # Calls the parent method to build the well_libraries
      super
    end

    def library_ids=(ids)
      # Don't update the used_aliquots if the feature flag is disabled
      unless Flipper.enabled?(:dpl_1112)
        super
        return
      end

      # Map the ids to integers as they may be strings
      ids.map!(&:to_i).each do |id|
        # If the used_aliquot already exists, skip it
        next if used_aliquots.find_by(source_id: id)

        # Create a new used_aliquot if it doesn't exist
        used_aliquots << used_aliquots.build(source_id: id, source_type: 'Pacbio::Library',
                                             volume: 0, concentration: 0, aliquot_type: :derived,
                                             template_prep_kit_box_barcode: '033000000000000000000')
      end

      # If the used_aliquot is not in the list of ids, remove it
      destroy_aliquots_by_source_type_and_id(ids, 'Pacbio::Library')

      # Calls the parent method to build the well_libraries
      super
    end

    # Destroy aliquots based on their source_id and type
    # Used to keep libraries, pools and aliqouts in sync
    def destroy_aliquots_by_source_type_and_id(ids, source_type)
      used_aliquots.select do |used_aliquot|
        ids.exclude?(used_aliquot.source_id) && used_aliquot.source_type == source_type
      end.each(&:destroy)
    end

    def tag_set
      all_libraries.collect(&:tag_set).first
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

    # A collection of all the libraries for a well
    def all_libraries
      pools.collect(&:libraries).flatten + libraries
    end

    # collection of all of the requests for a library
    # useful for messaging
    def request_libraries
      raise StandardError, 'Unsupported, fix this'
    end

    # a collection of all the sample names for a particular well
    # useful for comments
    def sample_names(separator = ':')
      all_libraries.collect(&:request).collect(&:sample_name).join(separator)
    end

    # a collection of all the tags for a well
    # useful to check whether they are unique
    def tags
      all_libraries.collect(&:tag_id)
    end

    def pools?
      pools.present?
    end

    def libraries?
      libraries.present?
    end

    def template_prep_kit_box_barcode
      if pools?
        pools.first.template_prep_kit_box_barcode
      elsif libraries?
        libraries.first.template_prep_kit_box_barcode
      end
    end

    def insert_size
      if pools?
        pools.first.insert_size
      elsif libraries?
        libraries.first.insert_size
      end
    end

    def collection?
      true
    end

    def adaptive_loading_check
      loading_target_p1_plus_p2.present?
    end
  end
end
