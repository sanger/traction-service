# frozen_string_literal: true

module Pacbio
  # Pacbio::Run
  class Run < ApplicationRecord
    enum sequencing_mode: %w[CLR CCS]

    validates :name, :template_prep_kit_box_barcode, :binding_kit_box_barcode,
              :sequencing_kit_box_barcode, :dna_control_complex_box_barcode,
              :sequencing_mode, presence: true

    has_one :plate, class_name: 'Pacbio::Plate', foreign_key: :pacbio_run_id,
                    dependent: :destroy, inverse_of: :run

    delegate :wells, to: :plate

    def comments
      super || wells.collect(&:summary).join(';')
    end
  end
end
