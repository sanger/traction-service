# frozen_string_literal: true

# Tube
class Tube < ApplicationRecord
  include Labware
  include Container

  # This validation probably *should* be always on. It doesn't seem to be violated in production
  # but engaging it does cause tests to fail.
  validates :barcode, presence: true, on: :reception

  has_many :pacbio_pools, dependent: :restrict_with_exception, class_name: 'Pacbio::Pool'
  has_one :pacbio_library, dependent: :restrict_with_exception, class_name: 'Pacbio::Library'
  has_many :ont_pools, dependent: :restrict_with_exception, class_name: 'Ont::Pool'
  has_many :ont_requests, through: :container_materials, source: :material,
                          source_type: 'Ont::Request', class_name: 'Ont::Request'
  has_many :pacbio_requests, through: :container_materials, source: :material,
                             source_type: 'Pacbio::Request', class_name: 'Pacbio::Request'

  scope :by_barcode, ->(*barcodes) { where(barcode: barcodes) }
  scope :by_pipeline,
        lambda { |pipeline|
          case pipeline
          when :pacbio
            left_outer_joins(:pacbio_pools, :pacbio_library, :pacbio_requests).where(
              'pacbio_pools.id IS NOT NULL OR pacbio_libraries.id IS NOT NULL OR
               pacbio_requests.id IS NOT NULL'
            )
          when :ont
            left_outer_joins(:ont_pools, :ont_requests).where(
              'ont_pools.id IS NOT NULL OR ont_requests.id IS NOT NULL'
            )
          else
            joins(:container_materials).where(
              'container_materials.material_type LIKE ?', "#{pipeline.capitalize}::%"
            )
          end
        }

  def identifier
    barcode
  end

  def position
    nil
  end

  def labware_type
    self.class.name.downcase
  end
end
