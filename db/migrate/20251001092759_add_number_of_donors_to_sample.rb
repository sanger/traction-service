class AddNumberOfDonorsToSample < ActiveRecord::Migration[8.0]
  def change
    add_column :samples, :number_of_donors, :integer
  end
end
