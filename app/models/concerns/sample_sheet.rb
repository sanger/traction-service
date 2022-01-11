# frozen_string_literal: true

# SampleSheet module
# provides the group of methods
# used to generate a pacbio run's sample sheet csv
# TODO: This is included in a couple of places, but only some of the methods work in each.
module SampleSheet
  # include ActiveSupport::Concern

  # Sample Well field
  def position_leading_zero
    "#{row}#{column.rjust(2, '0')}"
  end

  # Barcode Name field
  # Used in context of Request Library model
  def barcode_name
    tag&.barcode_name
  end

  # Barcode Set field
  def barcode_set
    # Assuming each request libraries tag has the same set name
    return unless all_libraries_tagged

    libraries.first.tag.barcode_set
  end

  # Sample bio Name field
  def find_sample_name
    if defined?(sample_names) # When row type is well
      return sample_names unless sample_is_barcoded
    elsif defined?(request.sample_name) # When row type is library (sample)
      return request.sample_name
    end
    ''
  end

  # Sample is Barcoded field
  def all_libraries_tagged
    libraries.all?(&:tag_id?)
  end

  # Used to indicate to the sample sheet whether it should treat a sample as barcoded
  # Note: This doesn't actually indicate that a sample *is* barcoded, as :hidden
  # tag sets (such as IsoSeq) lie.
  def sample_is_barcoded
    libraries.all? { |l| l.tag&.barcoded_for_sample_sheet? }
  end

  # Sample Name field
  def pool_barcode
    # First pool in well's barcode as samples names are already contained in bio sample name
    pools.first.tube.barcode
  end

  # Same Barcodes on Both Ends of Sequence field
  def same_barcodes_on_both_ends_of_sequence
    # Always true at the time of writing
    true
  end

  def automation_parameters
    return if pre_extension_time == 0
    return unless pre_extension_time

    "ExtensionTime=double:#{pre_extension_time}|ExtendFirst=boolean:True"
  end
end
