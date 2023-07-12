# frozen_string_literal: true

# Generate sample sheets for v12_revio
class PacbioSampleSheetV12Revio < PacbioSampleSheetCompiler
  # Executed once per well (`args[:context] == :well`) and library (`args[:context] == :library`)
  # the order columns is defined by the order of the hash
  # ```
  # args = {
  #   context: __, # (:well | :library)
  #   run: __, # (current run instance)
  #   plate: __, # (current plate instance)
  #   well: __, # (current well instance)
  #   library: __, # (current library instance)
  # }
  # ```
  COLUMN_CONFIG = {
    'Library Type': lambda { |args|
      args[:context] == :well ? 'Revio' : ''
    },
    'Reagent Plate': lambda { |_args|
      '1'
    },
    'Plate 1': lambda { |args|
      args[:plate].plate_number == 1 ? args[:plate].sequencing_kit_box_barcode : ''
    },
    'Plate 2': lambda { |args|
      args[:plate].plate_number == 2 ? args[:plate].sequencing_kit_box_barcode : ''
    },
    'Run Name': lambda { |args|
      args[:run].name
    },
    'Instrument Type': lambda { |args|
      args[:run].system_name
    },
    'Run Comments': lambda { |args|
      args[:run].comments
    },
    'Is Collection': lambda { |args|
      args[:well].collection?
    },
    'Sample Well': lambda { |args|
      args[:well].position_leading_zero
    },
    'Well Name': lambda { |args|
      args[:well].pool_barcode
    },
    'Movie Acquisition Time (hours)': lambda { |args|
      args[:well].movie_acquisition_time
    },
    'Include Base Kinetics': lambda { |args|
      args[:well].include_base_kinetics
    },
    'Library Concentration (pM)': lambda { |args|
      args[:well].library_concentration
    },
    'Polymerase Kit': lambda { |args|
      args[:well].polymerase_kit
    },
    'Automation Parameters': lambda { |args|
      args[:well].automation_parameters
    },
    'Adapters / Barcodes': lambda { |args|
      args[:well].barcode_set
    },
    'Barcode Name': lambda { |args|
      args[:context] == :library ? args[:library].barcode_name : args[:well].barcode_set
    },
    'Bio Sample Name': lambda { |args|
      args[:well].find_sample_name
    }
  }.freeze
end
