class UpdateTubesToBeContainers < ActiveRecord::Migration[6.0]
  def change
    execute <<~SQL
      INSERT INTO container_materials (container_type, container_id, material_type, material_id, created_at, updated_at)
      SELECT 'Tube', id, material_type, material_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM tubes;
    SQL

    remove_index :tubes, column: [:material_type, :material_id]
    remove_column :tubes, :material_type
    remove_column :tubes, :material_id
  end
end
