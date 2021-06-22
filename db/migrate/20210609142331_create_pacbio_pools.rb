class CreatePacbioPools < ActiveRecord::Migration[6.0]
  def change
    create_table :pacbio_pools do |t|
      t.belongs_to :tube, index: true
    end
  end
end
