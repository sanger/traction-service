# frozen_string_literal: true

# Handles the presentation of tag information to the sample sheet untagged
# libraries
# barcode_name => nil
# barcode_set => nil
# barcoded_for_sample_sheet? => false
# library_sample_name => 'my_sample'
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

  def library_sample_name(_library)
    library.request.sample_name || ''
  end
end
