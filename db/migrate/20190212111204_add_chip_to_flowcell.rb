class AddChipToFlowcell < ActiveRecord::Migration[5.2]
  def change
    add_reference :flowcells, :chip, foreign_key: true
  end
end
