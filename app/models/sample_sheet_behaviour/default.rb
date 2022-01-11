# frozen_string_literal: true

# Handles the presentation of tag information to the sample sheet for the majority of tag sets
# Given a tag with group_id example
# Will return
# barcode_name => example--example
class SampleSheetBehaviour::Default
  def initialize(tag)
    @tag = tag
  end

  def barcode_name
    "#{@tag.group_id}--#{@tag.group_id}"
  end

  def barcode_set
    @tag.tag_set.uuid
  end

  def barcoded_for_sample_sheet?
    true
  end
end
