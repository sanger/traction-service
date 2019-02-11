class AddEnzymeRefToLibraries < ActiveRecord::Migration[5.2]
  def change
    add_reference :libraries, :enzyme, foreign_key: true
  end
end
