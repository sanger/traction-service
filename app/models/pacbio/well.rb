# frozen_string_literal: true

module Pacbio
  # Pacbio::Well
  # A well can have many libraries
  class Well < ApplicationRecord
    GENERIC_KIT_BARCODE = 'Lxxxxx100938900123199'

    include Uuidable
    include SampleSheet::Well

    # We should get rid of the below enum,
    # as we are not supporting sequencing_mode in SMRTLink v10
    # but if we keep the field in the database, for auditing,
    # then we need this to translate the integer to a value
    enum sequencing_mode: { 'CLR' => 0, 'CCS' => 1 }

    enum generate_hifi: { 'In SMRT Link' => 0, 'On Instrument' => 1, 'Do Not Generate' => 2 }

    belongs_to :plate, class_name: 'Pacbio::Plate', foreign_key: :pacbio_plate_id,
                       inverse_of: :wells

    has_many :well_pools, class_name: 'Pacbio::WellPool', foreign_key: :pacbio_well_id,
                          dependent: :destroy, inverse_of: :well
    has_many :pools, class_name: 'Pacbio::Pool', through: :well_pools, autosave: true

    has_many :libraries, through: :pools
    has_many :tag_sets, through: :libraries

    validates :movie_time, :on_plate_loading_concentration,
              :row, :column, :generate_hifi, :binding_kit_box_barcode, presence: true
    validates :movie_time,
              numericality: { greater_than_or_equal_to: 0.1, less_than_or_equal_to: 30 }
    validates :pre_extension_time, numericality: { only_integer: true }, allow_blank: true
    validates :loading_target_p1_plus_p2,
              allow_blank: true,
              numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

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

    def ccs_analysis_output=(value)
      self[:ccs_analysis_output] = value.presence || 'No'
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
