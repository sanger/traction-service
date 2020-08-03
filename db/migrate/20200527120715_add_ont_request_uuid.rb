class AddOntRequestUuid < ActiveRecord::Migration[6.0]
  def change
    add_column :ont_requests, :uuid, :string, index: true
  end
end
