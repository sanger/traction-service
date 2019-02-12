class AddFlowcellToLibraries < ActiveRecord::Migration[5.2]
  def change
    add_reference :libraries, :flowcell, foreign_key: true
  end
end
