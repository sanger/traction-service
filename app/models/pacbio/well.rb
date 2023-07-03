# frozen_string_literal: true

module Pacbio
  # Pacbio::Well
  # A well can have many libraries
  class Well < ApplicationRecord
    GENERIC_KIT_BARCODE = 'Lxxxxx100938900123199'

    include Uuidable
    include SampleSheet::Well

    belongs_to :plate, class_name: 'Pacbio::Plate', foreign_key: :pacbio_plate_id,
                       inverse_of: :wells
    has_many :well_pools, class_name: 'Pacbio::WellPool', foreign_key: :pacbio_well_id,
                          dependent: :destroy, inverse_of: :well, autosave: true
    has_many :pools, class_name: 'Pacbio::Pool', through: :well_pools

    has_many :libraries, through: :pools
    has_many :tag_sets, through: :libraries

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

    validates :pools, length: {
      minimum: 1,
      message: :well_min_pools
    }

    delegate :run, to: :plate, allow_nil: true

    def tag_set
      tag_sets.first
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

    # return the sequencing_kit_box_barcode of this plate if well belongs to plate 1
    # used for 2-plate sample sheets
    def sequencing_kit_box_barcode_plate_1
      plate.plate_number == 1 ? plate.sequencing_kit_box_barcode : nil
    end

    # return the sequencing_kit_box_barcode of this plate if well belongs to plate 2
    # used for 2-plate sample sheets
    def sequencing_kit_box_barcode_plate_2
      plate.plate_number == 2 ? plate.sequencing_kit_box_barcode : nil
    end

    # collection of all of the requests for a library
    # useful for messaging
    def request_libraries
      raise StandardError, 'Unsupported, fix this'
    end

    # a collection of all the sample names for a particular well
    # useful for comments
    def sample_names(separator = ':')
      libraries.collect(&:request).collect(&:sample_name).join(separator)
    end

    # a collection of all the tags for a well
    # useful to check whether they are unique
    def tags
      libraries.collect(&:tag_id)
    end

    def pools?
      pools.present?
    end

    def template_prep_kit_box_barcode
      pools? ? pools.first.template_prep_kit_box_barcode : ''
    end

    def insert_size
      pools? ? pools.first.insert_size : ''
    end

    def collection?
      true
    end

    def adaptive_loading_check
      loading_target_p1_plus_p2.present?
    end
  end
end
