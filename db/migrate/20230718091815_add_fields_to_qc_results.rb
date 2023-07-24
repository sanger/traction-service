class AddFieldsToQcResults < ActiveRecord::Migration[7.0]
  def change
    add_column :qc_results, :priority_level, :string
    add_column :qc_results, :date_required_by, :string
    add_column :qc_results, :reason_for_priority, :string
  end
end
