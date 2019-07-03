# frozen_string_literal: true

module Pacbio
  # Pacbio::Run
  class Run < ApplicationRecord
    enum sequencing_mode: %w[CLR CCS]

    validates :name, :template_prep_kit_box_barcode, :binding_kit_box_barcode,
              :sequencing_kit_box_barcode, :dna_control_complex_box_barcode,
              :sequencing_mode, presence: true

    has_one :plate, foreign_key: :pacbio_run_id,
                    dependent: :destroy, inverse_of: :run

    delegate :wells, to: :plate

    def comments
      super || wells.collect(&:summary).join(';')
    end

    def test_csv

      CSV.open("file.csv", "wb") do |csv|

        columns = [
          "System name",
          "Run Name",
          "Sample Well",
          "Sample Name",
          "Movie Time per SMRT Cell (hours)",
          "Insert Size (bp)",
          "Template Prep Kit (Box Barcode)",
          "Binding Kit (Box Barcode)",
          "Sequencing Kit (Box Barcode)",
          "Sequencing Mode (CLR/ CCS ) ",
          "On plate loading concentration (mP)",
          "DNA Control Complex (Box Barcode)",
          "Generate CCS Data"
        ]

        csv << columns



        for well in self.wells
          data = []

          library = well.library
          sample = library.sample

          data << 'Sequel I' #make attribute on run
          data << self.name

          csv << data
        end

      end

    end

  end
end
