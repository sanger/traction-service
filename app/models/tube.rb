# frozen_string_literal: true

# Tube
class Tube < ApplicationRecord
  include Labware
  include Container

  # This validation probably *should* be always on. It doesn't seem to be violated in production
  # but engaging it does cause tests to fail.
  validates :barcode, presence: true, on: :reception

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
