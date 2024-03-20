# frozen_string_literal: true

# Handles the presentation of tag information to the sample sheet untagged
# libraries
# barcode_name => nil
# barcode_set => nil
# barcoded_for_sample_sheet? => false
# aliquot_sample_name => 'my_sample'
class SampleSheetBehaviour::Untagged < SampleSheetBehaviour::Default
  def barcode_name(_tag)
    nil
  end

  def barcode_set(_tag)
    nil
  end

  def barcoded_for_sample_sheet?
    false
  end

  def aliquot_sample_name(aliquot)
    aliquot.source.request.sample_name || ''
  end

  def show_row_per_sample?(_libraries)
    false
  end
end
