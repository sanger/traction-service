class AddDateSampleCollection < ActiveRecord::Migration[7.0]
  def change
    change_table :samples, bulk: true do |t|
      t.datetime :date_of_sample_collection, comment: 'Date of sample collection'
    end
  end
end
