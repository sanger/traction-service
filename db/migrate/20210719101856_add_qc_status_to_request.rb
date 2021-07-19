class AddQcStatusToRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :pacbio_requests, :qc_status, :integer, default: 0
  end
end
