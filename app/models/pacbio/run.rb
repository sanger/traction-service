# frozen_string_literal: true

module Pacbio
  # Pacbio::Run
  class Run < ApplicationRecord
    NAME_PREFIX = 'TRACTION-RUN-'

    include Uuidable
    include Stateful

    # Sequel II and Sequel I are now deprecated
    enum system_name: { 'Sequel II' => 0, 'Sequel I' => 1, 'Sequel IIe' => 2, 'Revio' => 3 }

    after_create :generate_name

    has_many :plates, foreign_key: :pacbio_run_id,
                      dependent: :destroy, inverse_of: :run, autosave: true

    # This association creates the link to the SmrtLinkVersion. Run belongs
    # to a SmrtLinkVersion. We set the default SmrtLinkVersion for the run
    # using the class method 'default'.
    belongs_to :smrt_link_version,
               class_name: 'Pacbio::SmrtLinkVersion',
               foreign_key: :pacbio_smrt_link_version_id,
               inverse_of: :runs,
               default: -> { SmrtLinkVersion.default }

    validates :sequencing_kit_box_barcode,
              :system_name, presence: true

    # it would be sensible to move this to dependent validation as with wells
    # and SMRT Link. Something to ponder on ...
    validates :dna_control_complex_box_barcode, presence: true, unless: lambda {
                                                                          system_name == 'Revio'
                                                                        }

    # if it is a Revio run we need to check if the wells are in the correct positions
    validates_with WellPositionValidator, if: lambda {
                                                system_name == 'Revio'
                                              }

    validates :name, uniqueness: { case_sensitive: false }

    validate :validate_plate_limit

    scope :active, -> { where(deactivated_at: nil) }

    accepts_nested_attributes_for :plates, allow_destroy: true

    # This will return an empty list
    # If plate/well data is required via the run, use ?include=plates.wells
    attr_reader :plates_attributes

    # if comments are nil this blows up so add try.
    def comments
      super || wells.try(:collect, &:summary).try(:join, ':')
    end

    # returns sample sheet csv for a Pacbio::Run
    # using pipelines.yml configuration to generate data
    def generate_sample_sheet
      sample_sheet = PacbioSampleSheet.new(run: self, configuration: pacbio_run_sample_sheet_config)
      sample_sheet.generate
    end

    # Revio has changed to use instrument_name
    # We can't alias it as it is an enum
    def instrument_name
      system_name
    end

    def wells
      plates.collect(&:wells).flatten
    end

    private

    # We now have SMRT Link versioning
    # This allows generation of sample sheets based on the SMRT Link version
    # Each different version of SMRT Link has different columns
    # A version can be assigned to a run but changed
    # e.g. Pipelines.pacbio.sample_sheet.by_version('v10')
    def pacbio_run_sample_sheet_config
      Pipelines.pacbio.sample_sheet.by_version(smrt_link_version.name)
    end

    def generate_name
      return if name.present?

      update(name: "#{NAME_PREFIX}#{id}")
    end

    def validate_plate_limit
      return if system_name.blank?

      if plates.size > 1 && system_name == 'Sequel IIe'
        errors.add(:plates,
                   'Sequel IIe can only have 1 plate')
      end
      return unless plates.size > 2 && system_name == 'Revio'

      errors.add(:plates,
                 'Revio can only have 2 plates')
    end
  end
end
