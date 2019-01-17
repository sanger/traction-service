class AddSampleRefToLibraries < ActiveRecord::Migration[5.2]
  def change
    add_reference :libraries, :sample, foreign_key: true
  end
end
