# frozen_string_literal: true

# Handles the presentation of tag information to the sample sheet for the majority of tag sets
# Given a tag with group_id example
# Will return
# barcode_name => example--example
class SampleSheetBehaviour::Default
  def barcode(tag)
    tag.group_id
  end

  def barcode_name(tag)
    "#{tag.group_id}--#{tag.group_id}"
  end

  def barcode_set(tag_set)
    tag_set.uuid
  end

  def barcoded_for_sample_sheet?
    true
  end

  def library_sample_name(library)
    library.request.sample_name || ''
  end

  def show_row_per_sample?(libraries)
    libraries.any?(&:tag_id?)
  end
end
