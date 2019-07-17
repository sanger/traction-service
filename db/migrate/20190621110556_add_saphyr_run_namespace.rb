class AddSaphyrRunNamespace < ActiveRecord::Migration[5.2]
  def change
    change_table :chips do |t|
      t.remove_references :run
      t.belongs_to :saphyr_run
    end

    rename_table :runs, :saphyr_runs
  end
end
