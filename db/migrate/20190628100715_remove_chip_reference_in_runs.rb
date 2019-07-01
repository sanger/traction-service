class RemoveChipReferenceInRuns < ActiveRecord::Migration[5.2]
  change_table :saphyr_runs do |t|
    t.remove_references :saphyr_chip
  end
end
