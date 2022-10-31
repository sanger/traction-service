class AddDecisionMadeByToQcResults < ActiveRecord::Migration[7.0]
  def change
    add_column :qc_results, :decision_made_by, :integer, null: false
  end
end
