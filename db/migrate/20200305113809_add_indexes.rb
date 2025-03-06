class AddIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :pacbio_request_libraries, [:tag_id, :pacbio_library_id], name: :index_rl_tag_library
    add_index :pacbio_request_libraries, [:pacbio_request_id, :pacbio_library_id], name: :index_rl_request_library
    add_index :pacbio_runs, :name, unique: true
    add_index :samples, :name, unique: true
    add_index :tags, [:oligo, :tag_set_id], unique: true
    add_index :tags, [:group_id, :tag_set_id], unique: true
  end
end
