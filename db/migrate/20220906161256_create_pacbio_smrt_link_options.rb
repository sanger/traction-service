class CreatePacbioSmrtLinkOptions < ActiveRecord::Migration[7.0]
  def change
    create_table :pacbio_smrt_link_options do |t|

      t.string :key, null: false, index: { unique: true }
      t.string :label, null: false
      t.string :default_value
      t.json :validations
      t.integer :data_type, default: 0
      t.text :select_options

      t.timestamps
    end
  end
end
