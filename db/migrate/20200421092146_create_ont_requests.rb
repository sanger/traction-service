class CreateOntRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :ont_requests do |t|
      t.belongs_to :container, polymorphic: true, index: true
      t.timestamps
    end
  end
end
