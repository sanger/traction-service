class AddSequencescapeRequestIdToSamples < ActiveRecord::Migration[5.2]
  def change
    add_column :samples, :sequencescape_request_id, :integer
  end
end
