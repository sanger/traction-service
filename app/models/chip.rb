# frozen_string_literal: true

# Chip
class Chip < ApplicationRecord
  belongs_to :run, optional: true
  has_many :flowcells, dependent: :nullify

  validates :barcode, presence: true
  validates :barcode, length: { minimum: 16 }

  before_save :update_serial_number

  private

  def update_serial_number
    self.serial_number = barcode[0..15]
  end
end
