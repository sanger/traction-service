# frozen_string_literal: true

class AddSpeciesToSamples < ActiveRecord::Migration[5.2]
  def change
    add_column :samples, :species, :string
  end
end
