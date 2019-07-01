class CreateSaphyrRequest < ActiveRecord::Migration[5.2]
  def change
    create_table :saphyr_requests do |t|
      t.integer :external_study_id
      t.belongs_to :sample
    end
  end
end
