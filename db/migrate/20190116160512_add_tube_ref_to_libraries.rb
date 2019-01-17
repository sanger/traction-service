class AddTubeRefToLibraries < ActiveRecord::Migration[5.2]
  def change
    add_reference :libraries, :tube, foreign_key: true
  end
end
