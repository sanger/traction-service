class CreateOntRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :ont_requests do |t|
      t.string :external_study_id
      t.timestamps
    end
  end
end
