# frozen_string_literal: true

# SampleSheet module
# Namespace for helper modules to assist ActiveRecord classes in rendering
# sample sheets
module SampleSheet
  # Provides run helper methods for sample sheet generation
  module Run
    # Returns a list of wells associated with all plates which are sorted by plate first and
    # then by wells in column order
    # Example: ([<Plate plate_number:1>
    #             [<Well position:'A1'>, <Well position:'A2'>,<Well position:'B1'>]<Plate>
    #           <Plate plate_number:2>
    #             [<Well position:'A3'>, <Well position:'A4'>,<Well position:'B3'>]<Plate>]) =>
    #       [<Well position:'A1'>, <Well position:'B1'>, <Well position:'A2'>,<Well position:'A3'>
    #        <Well position:'A3'>,<Well position:'B3'>,<Well position:'A4'>],
    def sorted_wells
      sorted_plates = plates.sort_by(&:plate_number)
      sorted_plates.flat_map { |plate| plate.wells.sort_by { |well| [well.column.to_i, well.row] } }
    end
  end

  # Provides well helper methods for sample sheet generation
  module Well
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
      sample_sheet_behaviour.show_row_per_sample?(all_libraries)
    end

    # Returns libraries only if they should be shown per row
    def libraries_to_show_per_row
      return unless show_row_per_sample?

      all_libraries
    end

    # Sample Name field
    def tube_barcode
      # Gets the firsts library barcode which will either be the pool barcode or the library barcode
      all_libraries.first.tube.barcode
    end

    # find the plate given the plate_number
    # returns `nil` if no plate found
    def get_plate(plate_number)
      plate.run.plates.filter { |plate| plate.plate_number == plate_number }.first
    end

    # return the sequencing_kit_box_barcode of plate 1
    # used for 2-plate sample sheets
    def sequencing_kit_box_barcode_plate_1
      get_plate(1)&.sequencing_kit_box_barcode
    end

    # return the sequencing_kit_box_barcode of plate 2
    # used for 2-plate sample sheets
    def sequencing_kit_box_barcode_plate_2
      get_plate(2)&.sequencing_kit_box_barcode
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
