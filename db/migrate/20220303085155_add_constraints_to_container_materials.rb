# frozen_string_literal: true

# During development I ended up with a couple of data-integrity issues
# due to missing validations allowing container_materials to save
# when their associated resources were invalid. Adding belt and braces
# approach to ensure we maintain data integrity. (Glance at production suggests
# data is currently valid)
#
# A similar constraint should probably be applied to material_id and
# material_type but we currently have invalid data here.
class AddConstraintsToContainerMaterials < ActiveRecord::Migration[6.0]
  def up
    say 'Checking existing data integrity'
    invalid_resources = ContainerMaterial.where(container_type: nil)
                                         .or(
                                           ContainerMaterial.where(container_id: nil)
                                          )
                                         .ids

    raise "Invalid resources #{invalid_resources}" unless invalid_resources.empty?

    say 'Updating columns'
    change_column :container_materials, :container_id, :bigint, null: false
    change_column :container_materials, :container_type, :string, null: false
  end

  def down
    change_column :container_materials, :container_id, :bigint, null: true
    change_column :container_materials, :container_type, :string, null: true
  end
end
