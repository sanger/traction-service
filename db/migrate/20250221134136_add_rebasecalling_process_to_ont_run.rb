class AddRebasecallingProcessToOntRun < ActiveRecord::Migration[7.2]
  def change
    add_column :ont_runs, :rebasecalling_process, :string
  end
end
