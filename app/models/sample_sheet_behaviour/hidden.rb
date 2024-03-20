# frozen_string_literal: true

# Handles the presentation of tag information to the sample sheet for tag sets
# where tag information is hidden from the sample sheet, eg. IsoSeq
# Given a tag with group_id example
# Will return
# barcode_name => nil
# barcode_set => nil
# barcoded_for_sample_sheet? => nil
# aliquot_sample_name => ''
class SampleSheetBehaviour::Hidden < SampleSheetBehaviour::Default
  def barcode_name(_tag)
    nil
  end

  def barcode_set(_tag)
    nil
  end

  def barcoded_for_sample_sheet?
    false
  end

  def aliquot_sample_name(_aliquot)
    ''
  end

  def show_row_per_sample?(_libraries)
    false
  end
end
