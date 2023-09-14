class AddPublicNameToSample < ActiveRecord::Migration[7.0]
  def change
    change_table :samples, bulk: true do |t|
      t.string :public_name, comment: 'Public name'
    end
  end
end