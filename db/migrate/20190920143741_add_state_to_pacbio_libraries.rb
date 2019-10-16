class AddStateToPacbioLibraries < ActiveRecord::Migration[5.2]
  def change
    add_column :pacbio_libraries, :state, :string
    add_column :pacbio_libraries, :deactivated_at, :datetime
  end
end
