class ModifyPacbioRequestLibrariesIndexes < ActiveRecord::Migration[6.0]
  def change
    remove_index :pacbio_request_libraries, name: :index_rl_tag_library
    add_index :pacbio_request_libraries, [:tag_id, :pacbio_library_id], name: :index_rl_tag_library, unique: true
    remove_index :pacbio_request_libraries, name: :index_rl_request_library
    add_index :pacbio_request_libraries, [:pacbio_request_id, :pacbio_library_id], name: :index_rl_request_library, unique: true
  end
end
