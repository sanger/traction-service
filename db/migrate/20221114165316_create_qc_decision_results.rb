class CreateQcDecisionResults < ActiveRecord::Migration[7.0]
  def change
    create_table :qc_decision_results do |t|
      t.references :qc_result, null: false, foreign_key: true
      t.references :qc_decision, null: false, foreign_key: true

      t.timestamps
    end
  end
end
