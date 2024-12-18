# frozen_string_literal: true

# namespace for handling different sample sheet behaviours
module SampleSheetBehaviour
  def self.get(behaviour_name)
    return Default.new if behaviour_name == 'default'

    Hidden.new # catch all. Works for untagged. Stopgap until full refactor
  end

  # barcode_name => example--example
  class Default
    # Deprecated as of SMRT-Link v13.0
    # See https://www.pacb.com/wp-content/uploads/SMRT-Link-Release-Notes-v13.0.pdf
    def barcode_name(tag)
      "#{tag.group_id}--#{tag.group_id}"
    end

    def barcode_set(tag_set)
      tag_set.uuid
    end

    def barcoded_for_sample_sheet?
      true
    end

    def aliquot_sample_name(aliquot)
      aliquot.source.sample_name || ''
    end

    def show_row_per_sample?(aliquots)
      aliquots.any?(&:tag_id?)
    end
  end

  # Handles the presentation of tag information to the sample sheet for tag sets
  # where tag information is hidden from the sample sheet, eg. IsoSeq
  # Given a tag with group_id example
  # Will return
  # barcode_name => nil
  # barcode_set => nil
  # barcoded_for_sample_sheet? => nil
  # aliquot_sample_name => ''
  class Hidden
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

    def show_row_per_sample?(_aliquots)
      false
    end
  end
end
