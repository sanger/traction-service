class AddForeignKeys < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :libraries, :samples
    add_foreign_key :libraries, :enzyme
    add_foreign_key :flowcells, :libraries
    add_foreign_key :flowcells, :chips
    add_foreign_key :runs, :chips
  end
end
