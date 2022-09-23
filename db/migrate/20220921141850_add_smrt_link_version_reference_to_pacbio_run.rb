class AddSmrtLinkVersionReferenceToPacbioRun < ActiveRecord::Migration[7.0]
  def change
    rename_column :pacbio_runs, :smrt_link_version, :smrt_link_version_deprecated
    change_column_null :pacbio_runs, :smrt_link_version_deprecated, true
    add_reference :pacbio_runs, :pacbio_smrt_link_version, foreign_key: true
  end
end
