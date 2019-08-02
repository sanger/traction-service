class DropPacbioTags < ActiveRecord::Migration[5.2]
  def change
    drop_table :pacbio_tags
  end
end
