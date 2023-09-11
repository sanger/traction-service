# frozen_string_literal: true

# Adding an optional column priority_level to samples to recieve this information
# from TOL through receptions endpoint
class AddPriorityLevelToSamples < ActiveRecord::Migration[7.0]
  def change
    change_table :samples, bulk: true do |t|
      t.string :priority_level, comment: 'Priority level e.g. Medium, High etc'
    end
  end
end
