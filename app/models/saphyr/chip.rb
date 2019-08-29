# frozen_string_literal: true

# Saphyr namespace
module Saphyr
  # Saphyr::Chip
  # A saphyr chip belongs to a saphyr run
  # A saphyr chip has many (two) flowcells
  class Chip < ApplicationRecord
    belongs_to :run, class_name: 'Saphyr::Run', foreign_key: 'saphyr_run_id',
                     optional: true, inverse_of: :chip

    has_many :flowcells, foreign_key: 'saphyr_chip_id', inverse_of: :chip, dependent: :nullify

    validates :barcode, presence: true
    validates :barcode, length: { minimum: 16 }

    before_save :update_serial_number

    private

    def update_serial_number
      self.serial_number = barcode[0..15]
    end
  end
end
