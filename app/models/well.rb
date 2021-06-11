# frozen_string_literal: true

# Well
class Well < ApplicationRecord
  include Container

  belongs_to :plate, inverse_of: :wells

  validates :position, presence: true

  def row
    position[0]
  end

  def column
    position[1..].to_i
  end

  def identifier
    "#{plate&.barcode}:#{position}"
  end

  def self.includes_args(except = nil)
    args = []
    args << { plate: Plate.includes_args(:wells) } unless except == :plate

    unless except == :container_materials
      args << { container_materials: ContainerMaterial.includes_args(:container) }
    end

    args
  end

  def self.resolved_query
    Well.includes(*includes_args)
  end
end
