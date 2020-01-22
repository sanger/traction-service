# frozen_string_literal: true

# SampleSheet module
# provides the group of methods
# used to generate a pacbio run's sample sheet csv
module SampleSheet
  # include ActiveSupport::Concern

  def position_leading_zero
    "#{row}#{column.rjust(2, '0')}"
  end

  # Barcode Name
  def barcode_name
    # e.g. tag1--tag1;samplename1|tag2--tag2;samplename2
    return unless all_libraries_tagged

    result = request_libraries.map do |rl|
      tag_group_id = rl.tag.group_id
      sample_name = rl.request.sample.name
      "#{tag_group_id}--#{tag_group_id};#{sample_name}"
    end

    return result.join('|')
  end

  # Barcode Set
  def barcode_set
    # Assuming each request libraries tag has the same set name
    return unless all_libraries_tagged

    request_libraries.first.tag.set_name
  end

  # Sample is Barcoded field
  def all_libraries_tagged
    number_of_request_libraries = request_libraries.length
    number_of_tags = tags.compact.length

    return number_of_request_libraries == number_of_tags
  end

  # Same Barcodes on Both Ends of Sequence field
  def same_barcodes_on_both_ends_of_sequence
    # Always true at the time of writing
    true
  end

  # Bio Sample Name
  def bio_sample_name
    sample_names
  end
end
