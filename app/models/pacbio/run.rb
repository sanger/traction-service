# frozen_string_literal: true

module Pacbio
  # Pacbio::Run
  class Run < ApplicationRecord
    NAME_PREFIX               = 'TRACTION-RUN-'
    DEFAULT_SMRT_LINK_VERSION = 'v10'

    include Uuidable
    include Stateful

    enum system_name: { 'Sequel II' => 0, 'Sequel I' => 1, 'Sequel IIe' => 2 }

    delegate :wells, :all_wells_have_pools?, to: :plate, allow_nil: true

    # This may seem like overkill but it will cover all bases
    # before_validation :update_smrt_link_version, on: :create
    after_create :generate_name

    has_one :plate, foreign_key: :pacbio_run_id,
                    dependent: :destroy, inverse_of: :run

    validates :sequencing_kit_box_barcode,
              :dna_control_complex_box_barcode,
              :system_name, presence: true

    validates :name, uniqueness: { case_sensitive: false }

    # validates :smrt_link_version, format: /\Av\d{2}?\.?\d{1,2}?\.?\d{1,3}\z/, allow_blank: true
    validates :smrt_link_version, format: Version::FORMAT, allow_blank: true

    scope :active, -> { where(deactivated_at: nil) }

    attribute :smrt_link_version, :string, default: DEFAULT_SMRT_LINK_VERSION

    def comments
      super || wells.collect(&:summary).join(':')
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
    # A version can be assigned to a run but changed.
    # We need to use send as it is dynamic
    # e.g. Pipelines.pacbio.sample_sheet.send('v10')
    # TODO: This would probably be better as a proper method
    # but as we create this dynamically might be too tricky for value
    def pacbio_run_sample_sheet_config
      Pipelines.pacbio.sample_sheet.send(smrt_link_version)
    end

    def generate_name
      return if name.present?

      update(name: "#{NAME_PREFIX}#{id}")
    end
  end
end
