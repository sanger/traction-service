# frozen_string_literal: true

# Well
class Well < ApplicationRecord
  include Container

  belongs_to :plate, inverse_of: :wells
  has_many :pacbio_requests, through: :container_materials, source: :material,
                             source_type: 'Pacbio::Request', class_name: 'Pacbio::Request'

  has_many :ont_requests, through: :container_materials, source: :material,
                          source_type: 'Ont::Request', class_name: 'Ont::Request'

  delegate :barcode, to: :plate, allow_nil: true

  validates :position, presence: true
  validates :barcode, presence: true, on: :reception

  scope :by_barcode, ->(*barcodes) { joins(:plate).where(plate: { barcode: barcodes }) }
  scope :by_barcode_and_position, lambda { |barcode, position|
    joins(:plate).where(plate: { barcode: }, position:)
  }

  def row
    position[0]
  end

  def column
    position[1..].to_i
  end

  def identifier
    "#{plate&.barcode}:#{position}"
  end

  def labware_type
    self.class.name.downcase
  end
end
