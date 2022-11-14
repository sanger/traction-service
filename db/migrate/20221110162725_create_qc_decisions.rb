class CreateQcDecisions < ActiveRecord::Migration[7.0]
  def change
    create_table :qc_decisions do |t|
      t.string :barcode
      t.string :status
      t.integer :decision_made_by

      t.timestamps
    end
  end
end
