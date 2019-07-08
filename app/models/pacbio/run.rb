# frozen_string_literal: true

module Pacbio
  # Pacbio::Run
  class Run < ApplicationRecord
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

    def test_csv
      # options: 'wb' is write and binary mode
      CSV.open('file.csv', 'wb') do |csv|
        headers = [
          'System name',
          'Run Name',
          'Sample Well',
          'Sample Name',
          'Movie Time per SMRT Cell (hours)',
          'Insert Size (bp)',
          'Template Prep Kit (Box Barcode)',
          'Binding Kit (Box Barcode)',
          'Sequencing Kit (Box Barcode)',
          'Sequencing Mode (CLR/ CCS ) ',
          'On plate loading concentration (mP)',
          'DNA Control Complex (Box Barcode)',
          'Generate CCS Data'
        ]
        csv << headers

        wells.each do |well|
          data = [
            system_name,
            name,
            well.position,
            well.library.sample.name,
            well.movie_time,
            well.insert_size,
            template_prep_kit_box_barcode,
            binding_kit_box_barcode,
            sequencing_kit_box_barcode,
            well.sequencing_mode,
            well.on_plate_loading_concentration,
            dna_control_complex_box_barcode,
            well.generate_ccs_data
          ]

          csv << data
        end

        csv
      end
    end
  end
end
