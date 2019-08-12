class RemoveChipReferenceInRuns < ActiveRecord::Migration[5.2]
  def change
    change_table :saphyr_runs do |t|
      t.remove_references :saphyr_chip
    end
  end
end
