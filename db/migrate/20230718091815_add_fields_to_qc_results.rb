class AddFieldsToQcResults < ActiveRecord::Migration[7.0]
  def change
    change_table :qc_results, bulk: true do |t|
      t.string :priority_level, comment: 'Priority level eg Medium, High etc'
      t.string :date_required_by, comment: 'Date required by eg tol, etc'
      t.text :reason_for_priority, comment: 'Reason for priority'
    end
  end
end
