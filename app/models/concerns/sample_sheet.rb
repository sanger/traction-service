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
    return if tag.blank?

    "#{tag.group_id}--#{tag.group_id}"
  end

  # Barcode Set field
  def barcode_set
    # Assuming each request libraries tag has the same set name
    return unless all_libraries_tagged

    libraries.first.tag.tag_set.uuid
  end

  # Sample bio Name field - TEMPORARY: Want well row to have sample_names when isoSeq tags
  def find_sample_name
    if defined?(sample_names) # When row type is well
      return sample_names unless check_library_tags
    elsif defined?(request.sample_name) # When row type is library (sample)
      return request.sample_name
    end
    ''
  end

  # Sample is Barcoded field
  def all_libraries_tagged
    libraries.all?(&:tag_id?)
  end

  # Sample is Barcoded field - TEMPORARY: Want IsoSeq samples to return false
  def check_library_tags
    isoseq_tag_sets = %w[IsoSeq_Primers_12_Barcodes_v1]
    if libraries.any? do |library|
         isoseq_tag_sets.include?(library.tag.tag_set.name) if library.tag
       end
      return false
    end

    libraries.all?(&:tag_id?)
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
