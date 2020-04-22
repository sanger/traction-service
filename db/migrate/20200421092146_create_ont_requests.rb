class CreateOntRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :ont_requests do |t|
      t.timestamps
    end
  end
end
