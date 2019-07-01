class AddSaphyrLibraryNamespace < ActiveRecord::Migration[5.2]
  def change
    change_table :saphyr_flowcells do |t|
      t.remove_references :library
      t.belongs_to :saphyr_library
    end

    rename_table :libraries, :saphyr_libraries
  end
end
