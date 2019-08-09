class CreateSaphyrEnzyme < ActiveRecord::Migration[5.2]
  def change
    change_table :saphyr_libraries do |t|
      t.remove_references :enzyme
      t.belongs_to :saphyr_enzyme
    end

    rename_table :enzymes, :saphyr_enzymes
  end
end
