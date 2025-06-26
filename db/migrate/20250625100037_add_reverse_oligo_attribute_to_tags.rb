class AddReverseOligoAttributeToTags < ActiveRecord::Migration[8.0]
  def up
    add_column :tags, :oligo_reverse, :string
  end

  def down
    remove_column :tags, :oligo_reverse
  end
end
