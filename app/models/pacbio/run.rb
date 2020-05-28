# frozen_string_literal: true

module Pacbio
  # Pacbio::Run
  class Run < ApplicationRecord
    NAME_PREFIX = 'TRACTION-RUN-'

    include Uuidable
    include Stateful

    enum system_name: { 'Sequel II' => 0, 'Sequel I' => 1 }

    delegate :wells, to: :plate

    after_create :generate_name

    has_one :plate, foreign_key: :pacbio_run_id,
                    dependent: :destroy, inverse_of: :run

    validates :template_prep_kit_box_barcode, :binding_kit_box_barcode,
              :sequencing_kit_box_barcode, :dna_control_complex_box_barcode,
              :system_name, presence: true

    validates :name, uniqueness: { case_sensitive: false }

    scope :active, -> { where(deactivated_at: nil) }

    def comments
      super || wells.collect(&:summary).join(',')
    end

    # returns sample sheet csv for a Pacbio::Run
    # using pipelines.yml configuration to generate data
    def generate_sample_sheet
      csv = ::CsvGenerator.new(run: self, configuration: pacbio_run_sample_sheet_config)
      csv.generate_sample_sheet
    end

    def traction_id
      "TRACTION-#{id}"
    end

    private

    def pacbio_run_sample_sheet_config
      Pipelines.pacbio.sample_sheet
    end

    def generate_name
      return if name.present?

      update(name: "#{NAME_PREFIX}#{id}")
    end
  end
end
