class AddSaphyrChipNamespace < ActiveRecord::Migration[5.2]
  def change
    change_table :flowcells do |t|
      t.remove_references :chip
      t.belongs_to :saphyr_chip
    end

    change_table :saphyr_runs do |t|
      t.remove_references :chip
      t.belongs_to :saphyr_chip
    end

    rename_table :chips, :saphyr_chips
  end
end
