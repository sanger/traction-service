class AddFieldsToPacbioTags < ActiveRecord::Migration[5.2]
  def change
     change_table :pacbio_tags do |t|
      t.integer :group_id
    end
  end
end
