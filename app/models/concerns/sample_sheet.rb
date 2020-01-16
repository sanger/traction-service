# frozen_string_literal: true

# SampleSheet module
# provides the group of methods
# used to generate a pacbio run's sample sheet csv
module SampleSheet
  # include ActiveSupport::Concern

  # Barcode Name
  def barcode_name
    # TODO: check what the barcode name is, library tags?
    'sample sheet module barcode name'
  end

  # Barcode Set
  def barcode_set
    # TODO: check what the barcode set is, tag groups?
    'barcode set'
  end

  # Sample is Barcoded field
  def all_libraries_tagged
    # TODO: check
    # return true when there is only one well libray
    # return true when all libraries are tagged
    # return false if any libraries are not tagged
    true
  end

  # Same Barcodes on Both Ends of Sequence field
  def same_barcodes_on_both_ends_of_sequence
    true
  end

  # Bio Sample Name
  def bio_sample_name
    sample_names
  end
end
