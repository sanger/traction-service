class SetPacbioRunDefaultToSequelIIe < ActiveRecord::Migration[7.0]
  def change
    change_column_default :pacbio_runs, :system_name, from: 0, to: 2
  end
end
