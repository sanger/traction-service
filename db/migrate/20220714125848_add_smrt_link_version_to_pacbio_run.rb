class AddSmrtLinkVersionToPacbioRun < ActiveRecord::Migration[7.0]
  def change
    add_column :pacbio_runs, :smrt_link_version, :string
  end
end
