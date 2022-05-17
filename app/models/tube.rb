# frozen_string_literal: true

# Tube
class Tube < ApplicationRecord
  include Labware
  include Container

  has_many :pacbio_pools, dependent: :restrict_with_exception, class_name: 'Pacbio::Pool'

  scope :by_barcode, ->(*barcodes) { where(barcode: barcodes) }
  scope :by_pipeline,
        lambda { |pipeline|
          joins(:container_materials).where(
            'container_materials.material_type LIKE ?', "#{pipeline.capitalize}::%"
          )
        }

  def identifier
    barcode
  end
end
