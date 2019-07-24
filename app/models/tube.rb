# frozen_string_literal: true

# Tube
class Tube < ApplicationRecord
  belongs_to :material, inverse_of: :tube, polymorphic: true

  after_create :generate_barcode

  scope :by_barcode, ->(*barcodes) { where(barcode: barcodes) }

  def pipeline
    material_type.deconstantize.constantize
  end

  private

  def generate_barcode
    update(barcode: "TRAC-#{id}")
  end


end
