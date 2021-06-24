# frozen_string_literal: true

# We'll populate the existing tag set information
class PopulateTagSetPipelineColumn < ActiveRecord::Migration[6.0]

  TAG_SET_PIPELINES = {
    'Sequel_16_barcodes_v3' => :pacbio,
    'ONT_EXP-PBC096' => :ont,
    'OntWell96Samples' => :ont # Only seen in UAT
  }
  # Just so we don't blow up on dev databases
  DEFAULT_PIPELINE = :pacbio

  def up
    say 'Updating tag sets'
    TagSet.find_each do |tag_set|
      say "Updating #{tag_set.id}: #{tag_set.name}"
      tag_set.update!(pipeline: TAG_SET_PIPELINES.fetch(tag_set.name, DEFAULT_PIPELINE))
    end
  end

  def down
    say 'Reverting tag sets'
    TagSet.find_each do |tag_set|
      say "Reverting #{tag_set.id}: #{tag_set.name}"
      tag_set.update!(pipeline: nil)
    end
  end
end
