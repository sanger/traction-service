class CreatePacbioWellPools < ActiveRecord::Migration[6.0]
  def change
    create_table :pacbio_well_pools do |t|
      t.belongs_to :pacbio_well, index: true
      t.belongs_to :pacbio_pool, index: true
    end
  end
end
