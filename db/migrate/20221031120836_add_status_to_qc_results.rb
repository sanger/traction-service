class AddStatusToQcResults < ActiveRecord::Migration[7.0]
  def change
    add_column :qc_results, :status, :string
  end
end