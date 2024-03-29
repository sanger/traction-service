class CreateAliquots < ActiveRecord::Migration[7.1]
  def change
    create_table :aliquots do |t|
      t.float :volume
      t.float :concentration
      t.string :template_prep_kit_box_barcode
      t.integer :insert_size
      t.string :uuid
      t.integer :state, null: false, default: 0
      t.integer :aliquot_type, null: false, default: 0
      t.belongs_to :tag, index: true
      t.belongs_to :source, polymorphic: true, index: true
      t.timestamps
    end
  end
end
