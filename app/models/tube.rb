# frozen_string_literal: true

# Tube
class Tube < ApplicationRecord
  include Labware
  belongs_to :material, inverse_of: :tube, polymorphic: true

  scope :by_barcode, ->(*barcodes) { where(barcode: barcodes) }
  scope :by_pipeline, ->(pipeline) { where('material_type LIKE ?', "#{pipeline.capitalize}::%") }
end
