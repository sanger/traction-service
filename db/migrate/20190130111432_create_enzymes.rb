class CreateEnzymes < ActiveRecord::Migration[5.2]
  def change
    create_table :enzymes do |t|
      t.string :name
    end
  end
end
