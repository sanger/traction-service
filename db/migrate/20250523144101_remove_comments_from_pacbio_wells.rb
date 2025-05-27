class RemoveCommentsFromPacbioWells < ActiveRecord::Migration[8.0]
  def change
    remove_column :pacbio_wells, :comment
  end
end
