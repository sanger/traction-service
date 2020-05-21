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
    position[1..-1].to_i
  end

  def resolved_well
    self.class.resolved_query.find(id)
  end

  def self.includes_args(except = nil)
    if except == :plate
      [container_materials: ContainerMaterial.includes_args(:container)]
    elsif except == :container_materials
      [plate: Plate.includes_args(:wells)]
    else
      [container_materials: :material, plate: Plate.includes_args(:wells)]
    end
  end

  def self.resolved_well(id:)
    resolved_query.find(id)
  end

  def self.all_resolved_wells
    resolved_query.all
  end

  def self.resolved_query
    Well.includes(*includes_args)
  end
end
