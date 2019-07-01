class CreatePacbioTag < ActiveRecord::Migration[5.2]
  def change
    create_table :pacbio_tags do |t|
      t.string :oligo
      t.timestamps
    end
  end
end
