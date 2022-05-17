# frozen_string_literal: true

# ContainerMaterial
# A container_material provides a link between containers and materials
# This means that a material can belong to more than one container
# And a container can have more than one type of material
class ContainerMaterial < ApplicationRecord
  belongs_to :container, polymorphic: true, optional: false
  belongs_to :material, polymorphic: true, optional: false
end
