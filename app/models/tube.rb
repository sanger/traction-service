# frozen_string_literal: true

# Tube
class Tube < ApplicationRecord
  belongs_to :material, inverse_of: :tube, polymorphic: true

  after_create :generate_barcode

  scope :by_barcode, ->(*barcodes) { where(barcode: barcodes) }

  scope :saphyr_tubes, -> { where('material_type LIKE ?', "Saphyr::%") }
  scope :pacbio_tubes, -> { where('material_type LIKE ?', "Pacbio::%") }

  private

  def generate_barcode
    update(barcode: "TRAC-#{id}")
  end

end
