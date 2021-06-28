# frozen_string_literal: true

# Make the pipeline column required
class MakeTagSetPipelineRequeired < ActiveRecord::Migration[6.0]
  def change
    change_column_null :tag_sets, :pipeline, false
  end
end
