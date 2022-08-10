class AddSmrtLinkOptionsToPacbioWell < ActiveRecord::Migration[7.0]
  def change
    add_column :pacbio_wells, :smrt_link_options, :json
  end
end
