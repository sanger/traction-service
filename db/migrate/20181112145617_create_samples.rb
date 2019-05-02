# frozen_string_literal: true

class CreateSamples < ActiveRecord::Migration[5.2]
  def change
    create_table :samples do |t|
      t.string :name
      t.datetime :deactivated_at
      t.string :external_id
      t.string :external_study_id
      t.string :species
      t.timestamps
    end
  end
end
