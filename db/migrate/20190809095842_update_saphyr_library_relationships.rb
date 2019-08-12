class UpdateSaphyrLibraryRelationships < ActiveRecord::Migration[5.2]
  def change
    change_table :saphyr_libraries do |t|
      t.remove_references :sample
    end

    change_table :saphyr_libraries do |t|
      t.belongs_to :saphyr_request
    end
  end
end
