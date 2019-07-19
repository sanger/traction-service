class ChangeSphyrRequestsExternalStudyIdType < ActiveRecord::Migration[5.2]
  def change
      change_column :saphyr_requests, :external_study_id, :string
  end
end
