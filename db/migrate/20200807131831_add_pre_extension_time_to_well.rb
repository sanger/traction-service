class AddPreExtensionTimeToWell < ActiveRecord::Migration[6.0]
  def change
    add_column :pacbio_wells, :pre_extension_time, :integer
  end
end
