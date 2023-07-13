# frozen_string_literal: true

# Generate sample sheets for v10
class PacbioSampleSheetV10 < PacbioSampleSheetCompiler
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
    'System Name': ->(args) { args[:run].system_name },
    'Run Name': ->(args) { args[:run].name },
    'Is Collection': ->(args) { args[:well].collection? },
    'Sample Well': ->(args) { args[:well].position_leading_zero },
    'Sample Name': ->(args) { args[:well].pool_barcode },
    'Movie Time per SMRT Cell (hours)': ->(args) { args[:well].movie_time.to_s },
    'Insert Size (bp)': ->(args) { args[:well].insert_size.to_s },
    'Template Prep Kit Box Barcode': ->(args) { args[:well].template_prep_kit_box_barcode },
    'Binding Kit Box Barcode': ->(args) { args[:well].binding_kit_box_barcode },
    'Sequencing Kit Box Barcode': ->(args) { args[:well].plate.sequencing_kit_box_barcode },
    'On-Plate Loading Concentration (pM)': lambda { |args|
      args[:well].on_plate_loading_concentration.to_s
    },
    'DNA Control Complex Box Barcode': lambda { |args|
      args[:well].plate.run.dna_control_complex_box_barcode
    },
    'Run Comments': ->(args) { args[:well].plate.run.comments },
    'Sample is Barcoded': ->(args) { args[:well].sample_is_barcoded.to_s },
    'Barcode Name': ->(args) { args[:context] == :library ? args[:well].find_sample_name : '' },
    'Barcode Set': ->(args) { args[:well].barcode_set },
    'Same Barcodes on Both Ends of Sequence': lambda { |args|
      args[:well].same_barcodes_on_both_ends_of_sequence.to_s
    },
    'Bio Sample Name': ->(args) { args[:well].find_sample_name }, # TODO: confirm these values
    'Automation Parameters': ->(args) { args[:well].automation_parameters },
    'Generate HiFi Reads': ->(args) { args[:well].generate_hifi },
    'CCS Analysis Output - Include Kinetics Information': lambda { |args|
      args[:well].ccs_analysis_output
    },
    'Loading Target (P1 + P2)': ->(args) { args[:well].loading_target_p1_plus_p2.to_s },
    'Use Adaptive Loading': ->(args) { args[:well].adaptive_loading_check.to_s }

  }.freeze
end
