class ChangePacbioRequestsExternalStudyIdType < ActiveRecord::Migration[5.2]
  def change
    change_column :pacbio_requests, :external_study_id, :string
  end
end
