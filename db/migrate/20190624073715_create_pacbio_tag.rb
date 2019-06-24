class CreatePacbioTag < ActiveRecord::Migration[5.2]
  def change
    create_table :pacbio_tags do |t|
      t.string :oligo
      t.belongs_to :pacbio_library, index: true
      t.timestamps
    end
  end
end
