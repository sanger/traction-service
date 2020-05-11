class UpdateOntRequest < ActiveRecord::Migration[6.0]
  def change
    remove_column :ont_requests, :external_study_id, :string
    add_column :ont_requests, :name, :string
    add_column :ont_requests, :external_id, :string
  end
end
