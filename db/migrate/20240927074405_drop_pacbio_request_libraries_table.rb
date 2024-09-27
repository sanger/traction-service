class DropPacbioRequestLibrariesTable < ActiveRecord::Migration[7.2]
  def change
    drop_table :pacbio_request_libraries
  end
end
