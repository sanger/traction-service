class AddIndexToNameForOntLibraries < ActiveRecord::Migration[6.0]
  def change
    add_index :ont_libraries, :name, unique: true
  end
end
