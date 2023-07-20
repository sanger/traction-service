# frozen_string_literal: true

# SampleSheet module
# Namespace for helper modules to assist ActiveRecord classes in rendering
# sample sheets
module SampleSheet
  # Provides run helper methods for sample sheet generation
  module Run
    # Returns a list of wells associated with the plate in column order
    # Example: [<Well position:'A1'>, <Well position:'A2'>, <Well position:'B1'>]) =>
    #          [<Well position:'A1'>, <Well position:'B1'>, <Well position:'A2'>]
    def sorted_wells
      wells.sort_by { |well| [well.column.to_i, well.row] }
    end
  end

  # Provides well helper methods for sample sheet generation
  module Well
    # The sequencing_kit_box_barcode of this plate if well belongs to plate 1
    # used for 2-plate sample sheets
    def sequencing_kit_box_barcode_plate_1
      plate.sequencing_kit_box_barcode if plate.plate_number == 1
    end

    # The sequencing_kit_box_barcode of this plate if well belongs to plate 2
    # used for 2-plate sample sheets
    def sequencing_kit_box_barcode_plate_2
      plate.sequencing_kit_box_barcode if plate.plate_number == 2
    end

    # Sample Well field
    def position_leading_zero
      "#{row}#{column.rjust(2, '0')}"
    end

    # Barcode Set field
    def barcode_set
      # Assuming each request libraries tag has the same set name
      sample_sheet_behaviour.barcode_set(tag_set)
    end

    # Determines rendering of a row-per sample
    def show_row_per_sample?
      sample_sheet_behaviour.show_row_per_sample?(libraries)
    end

    # Returns libraries only if they should be shown per row
    def libraries_to_show_per_row
      return unless show_row_per_sample?

      libraries
    end

    # Sample Name field
    def pool_barcode
      # First pool in well's barcode as samples names are already contained in bio sample name
      pools.first.tube.barcode
    end

    # Used to indicate to the sample sheet whether it should treat a sample as barcoded
    # Note: This doesn't actually indicate that a sample *is* barcoded, as :hidden
    # tag sets (such as IsoSeq) lie.
    def sample_is_barcoded
      sample_sheet_behaviour.barcoded_for_sample_sheet?
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

    # Sample bio Name field
    def find_sample_name
      sample_is_barcoded ? nil : sample_names
    end
  end

  # Provides library helper methods for sample sheet generation
  module Library
    # Barcode Name field
    # Used in context of Pacbio::Library model
    def barcode_name
      sample_sheet_behaviour.barcode_name(tag)
    end

    # Sample bio Name field
    def find_sample_name
      sample_sheet_behaviour.library_sample_name(self)
    end
  end
end
