# frozen_string_literal: true

# SampleSheet module
# provides the group of methods
# used to generate a pacbio run's sample sheet csv
module SampleSheet
  # include ActiveSupport::Concern

  # position_leading_zero
  # sample_names?

  def position_leading_zero
    "#{row}#{column.rjust(2, '0')}"
  end

  # Barcode Name
  def barcode_name
    # TODO: check library tags
    'sample sheet module barcode name'
  end

  # Barcode Set
  def barcode_set
    # TODO: check
    # Is this the well.libraries(&:tag)(&:group) ??
    # Do all the groups have to be the same within a well
    'barcode set'
  end

  # Sample is Barcoded field
  def all_libraries_tagged
    # if there is one sample with no tag, return false
    # if there is one sample with a tag, return true
    # if there is multiple samples all with tags, return true
    # if there is multiple samples, where only some have tags, return false
    true
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
