class AddTubeToPacbioLibrary < ActiveRecord::Migration[7.1]
  def change
    add_reference :pacbio_libraries, :tube, null: true, foreign_key: true
  end
end
