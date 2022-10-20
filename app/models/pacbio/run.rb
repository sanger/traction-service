# frozen_string_literal: true

module Pacbio
  # Pacbio::Run
  class Run < ApplicationRecord
    NAME_PREFIX = 'TRACTION-RUN-'

    include Uuidable
    include Stateful

    enum system_name: { 'Sequel II' => 0, 'Sequel I' => 1, 'Sequel IIe' => 2 }

    delegate :wells, :all_wells_have_pools?, to: :plate, allow_nil: true

    after_create :generate_name

    has_one :plate, foreign_key: :pacbio_run_id,
                    dependent: :destroy, inverse_of: :run

    # This association creates the link to the SmrtLinkVersion. Run belongs
    # to a SmrtLinkVersion. We set the default SmrtLinkVersion for the run
    # using the class method 'default'.
    belongs_to :smrt_link_version,
               class_name: 'Pacbio::SmrtLinkVersion',
               foreign_key: :pacbio_smrt_link_version_id,
               inverse_of: :runs,
               default: -> { SmrtLinkVersion.default }

    validates :sequencing_kit_box_barcode,
              :dna_control_complex_box_barcode,
              :system_name, presence: true

    validates :name, uniqueness: { case_sensitive: false }

    scope :active, -> { where(deactivated_at: nil) }

    # if comments are nil this blows up so add try.
    def comments
      super || wells.try(:collect, &:summary).try(:join, ':')
    end

    # returns sample sheet csv for a Pacbio::Run
    # using pipelines.yml configuration to generate data
    def generate_sample_sheet
      csv = ::CsvGenerator.new(run: self, configuration: pacbio_run_sample_sheet_config)
      csv.generate_sample_sheet
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
  end
end
