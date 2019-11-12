class RemoveExternalSutdyIdFromSamples < ActiveRecord::Migration[5.2]
  def change
    remove_column :samples, :external_study_id, :string
  end
end
