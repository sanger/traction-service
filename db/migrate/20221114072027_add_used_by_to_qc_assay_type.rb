class AddUsedByToQcAssayType < ActiveRecord::Migration[7.0]
  def up
    say 'adding used_by to qc_assay_types'
    add_column :qc_assay_types, :used_by, :integer
  end

  def down
    say 'removing used_by from qc_assay_types'
    remove_column :qc_assay_types, :used_by
  end
end