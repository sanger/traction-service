# frozen_string_literal: true

# Tube
class Tube < ApplicationRecord
  include Labware
  include Container

  scope :by_barcode, ->(*barcodes) { where(barcode: barcodes) }
  scope :by_pipeline, ->(pipeline) { joins(:container_material).where('container_materials.material_type LIKE ?', "#{pipeline.capitalize}::%") }
end
