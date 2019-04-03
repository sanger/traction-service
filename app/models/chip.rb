# frozen_string_literal: true

# Chip
class Chip < ApplicationRecord
  belongs_to :run, optional: true
  has_many :flowcells, dependent: :nullify

  validates :barcode, presence: true
  validates_length_of :barcode, minimum: 16

  after_create :create_flowcells
  before_save :update_serial_number

  private

  def create_flowcells
    Flowcell.create([{ position: 1, chip: self }, { position: 2, chip: self }])
  end

  def update_serial_number
    self.serial_number = self.barcode[0..15]
  end
end
