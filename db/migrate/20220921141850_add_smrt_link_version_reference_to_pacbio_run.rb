
# In this schema migration, we change smrt_link_version column of Pacbio runs
# from a string to a reference.

# 1) we rename the old string smrt_link_version column of Pacbio runs by adding
# a '_deprecated' suffix. We still need the column value because we will set 
# the new pacbio smrt_link_version reference by checking the version name. We 
# will assign versions using the data migration task in
# lib/tasks/migrate_pacbio_run_smrt_link_versions.rake .
# 2) we remove the null constraint from the smrt_link_version_deprecated column
# to avoid constraint violation for new runs.
# 3) We create a link from pacbio_run to the pacbio_smrt_link_version. 

class AddSmrtLinkVersionReferenceToPacbioRun < ActiveRecord::Migration[7.0]
  def change
    rename_column :pacbio_runs, :smrt_link_version, :smrt_link_version_deprecated
    change_column_null :pacbio_runs, :smrt_link_version_deprecated, true
    add_reference :pacbio_runs, :pacbio_smrt_link_version, foreign_key: true
  end
end
