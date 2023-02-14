class AddUuidToOntPool < ActiveRecord::Migration[7.0]
  def change
    add_column :ont_pools, :uuid, :string, null: false
  end
end
