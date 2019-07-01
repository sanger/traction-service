class CreatePacbioPlate < ActiveRecord::Migration[5.2]
  def change
    create_table :pacbio_plates do |t|
      t.belongs_to :pacbio_run, index: true
      t.timestamps
    end
  end
end
