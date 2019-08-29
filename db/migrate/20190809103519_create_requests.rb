class CreateRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :requests do |t|
      t.belongs_to :sample, index: true
      t.references :requestable, polymorphic: true, index: true
      t.timestamps
    end
  end
end
