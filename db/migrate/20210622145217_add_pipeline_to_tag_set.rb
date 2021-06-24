# frozen_string_literal: true

# Adds an pipeline column to tag sets
class AddPipelineToTagSet < ActiveRecord::Migration[6.0]
  def change
    add_column :tag_sets, :pipeline, :integer, index: true
  end
end
