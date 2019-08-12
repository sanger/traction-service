class CreatePacbioRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :pacbio_requests do |t|
      t.string :library_type
      t.integer :estimate_of_gb_required
      t.integer :number_of_smrt_cells
      t.string :cost_code
      t.string :external_study_id
      t.timestamps
    end
  end
end
