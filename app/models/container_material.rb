# frozen_string_literal: true

# ContainerMaterial
# A container_material provides a link between containers and materials
# This means that a material can belong to more than one container
# And a container can have more than one type of material
class ContainerMaterial < ApplicationRecord
  belongs_to :container, polymorphic: true
  belongs_to :material, polymorphic: true

  def self.includes_args(except = nil)
    if except == :container
      [:material]
    elsif except == :material
      [:container]
    else
      [:container, :material]
    end
  end
end
