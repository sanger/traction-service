class CreateOntMinKnowVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :ont_min_know_versions do |t|
      t.string :name, null: false, index: {unique: true}
      t.boolean :default, default: false
      t.boolean :active, default: true
   
      t.timestamps
    end

    add_reference :ont_runs, :ont_min_know_version, foreign_key: true
  end
end
