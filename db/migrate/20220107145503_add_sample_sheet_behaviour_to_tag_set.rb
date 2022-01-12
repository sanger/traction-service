# frozen_string_literal: true

# Adds a column to track the custom behaviours for different tag set presentation
# in the sample sheet. It may be that this behaviour ends up better located on
# library_type, but currently that's just a string.
class AddSampleSheetBehaviourToTagSet < ActiveRecord::Migration[6.0]
  def change
    add_column :tag_sets, :sample_sheet_behaviour, :integer, null: false, default: 0
  end
end
