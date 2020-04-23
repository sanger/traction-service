# frozen_string_literal: true

# ContainerMaterialFactory
# The factory will build a container-material join object
class ContainerMaterialFactory
  include ActiveModel::Model

  validate :check_container_material

  def initialize(attributes)
    @container_material = ContainerMaterial.new(attributes.extract!(:material, :container))
  end

  attr_reader :container_material

  def save
    return false unless valid?

    container_material.save
    true
  end

  private

  def check_container_material
    return if container_material.valid?

    container_material.errors.each do |k, v|
      errors.add(k, v)
    end
  end
end
