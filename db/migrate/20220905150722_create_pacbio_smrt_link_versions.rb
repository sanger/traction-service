class CreatePacbioSmrtLinkVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :pacbio_smrt_link_versions do |t|
      t.string :name, null: false, index: {unique: true}
      t.boolean :default, default: false
      t.boolean :active, default: true
   
      t.timestamps
    end
  end
end
