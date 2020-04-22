# frozen_string_literal: true

# ContainerMaterial
# A container_material provides a link between receptacles and materials
# This means that a material can belong to more than one container
# And a container can have more than one type of material
class ContainerMaterial < ApplicationRecord
  belongs_to :receptacle, polymorphic: true
  belongs_to :material, polymorphic: true
end
