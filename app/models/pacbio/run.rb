# frozen_string_literal: true

module Pacbio
  # Pacbio::Run
  class Run < ApplicationRecord
    include Uuidable

    enum sequencing_mode: %w[CLR CCS]
    enum system_name: ['Sequel II', 'Sequel I']

    validates :name, :template_prep_kit_box_barcode, :binding_kit_box_barcode,
              :sequencing_kit_box_barcode, :dna_control_complex_box_barcode,
              :system_name, presence: true

    has_one :plate, foreign_key: :pacbio_run_id,
                    dependent: :destroy, inverse_of: :run

    delegate :wells, to: :plate

    def comments
      super || wells.collect(&:summary).join(';')
    end

    # returns sample sheet csv for a Pacbio::Run
    # using pipelines.yml configuration to generate data
    def generate_sample_sheet
      csv = ::CSVGenerator.new(run: self, configuration: pacbio_run_sample_sheet_config)
      csv.generate_sample_sheet
    end

    private

    def pacbio_run_sample_sheet_config
      Pipelines.pacbio.sample_sheet
    end
  end
end
