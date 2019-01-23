class AddDeactivateAtToLibraries < ActiveRecord::Migration[5.2]
  def change
    add_column :libraries, :deactivated_at, :datetime
  end
end
