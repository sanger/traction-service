# frozen_string_literal: true

# Handles the presentation of tag information to the sample sheet for tag sets
# where tag information is hidden from the sample sheet, eg. IsoSeq
# Given a tag with group_id example
# Will return
# barcode_name => nil
class SampleSheetBehaviour::Hidden < SampleSheetBehaviour::Default
  def barcode_name
    nil
  end

  def barcode_set
    nil
  end

  def barcoded_for_sample_sheet?
    false
  end
end
