# frozen_string_literal: true

# We'll add a few constraints to the database to help maintain data integrity
class AddLibraryDatabaseConstraints < ActiveRecord::Migration[6.0]
  def change
    change_column_null :pacbio_libraries, :pacbio_request_id, false
    change_column_null :pacbio_libraries, :pacbio_pool_id, false
    add_foreign_key :pacbio_libraries, :pacbio_requests
    add_foreign_key :pacbio_libraries, :pacbio_pools
  end
end
