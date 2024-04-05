# frozen_string_literal: true

# A class spefically for SMRT-Link v13 Sample Sheets, based on the PacbioSampleSheet class

module RunCsv
  # RunCsv::PacbioSampleSheetV13
  # Used to generate sample sheets specific to the PacBio pipeline for v13
  class PacbioSampleSheetV13 < PacbioSampleSheet
    # Generate a hash of settings for the run
    def run_settings
      run = object # Pacbio::Run
      first_plate = run.plates[0]
      second_plate = run.plates[1]
      {
        'Instrument Type' => run.system_name, # Revio
        'Run Name' =>	run.name, # TRACTION-RUN-1042
        'Run Comments' =>	run.comments, # TRAC-2-7242 245pM TRAC-2-782 247pM
        'Plate 1' =>	first_plate.sequencing_kit_box_barcode, # 1021188000328660070020240502
        'Plate 2' =>	second_plate&.sequencing_kit_box_barcode, # 1021188000328660070020240503
        'CSV Version' =>	1
      }
    end

    # Generate a list of plate-well identifiers.
    # Eg. ['1_A01', '1_A02', '2_A01', ...]
    def plate_well_names
      wells = object.plates.flat_map(&:wells)
      wells.map do |well|
        "#{well.plate.plate_number}_#{well.position_leading_zero}"
      end
    end

    # Generate a hash of settings for a single cell
    def generate_smrt_cell_settings(well) # rubocop:disable Metrics/MethodLength
      {
        'Well Name'	=> well.pools.first.tube.barcode, # TRAC-2-7242
        'Library Type'	=> 'Standard', # (potentially new field otherwise just string)
        'Movie Acquisition Time (hours)'	=> well.movie_acquisition_time, # 24
        'Insert Size (bp)'	=> well.insert_size, # 500
        'Assign Data To Project'	=> 1, # (maybe we need to assign a run a project in traction)?
        'Library Concentration (pM)'	=> well.library_concentration, # 250
        'Include Base Kinetics'	=> well.include_base_kinetics, # FALSE
        'Polymerase Kit'	=> well.polymerase_kit, # 032037102739100071224
        'Indexes'	=> well.barcode_set, # 244d96c6-f3b2-4997-5ae3-23ed33ab925f
        'Sample is indexed'	=> well.collection?, # TRUE
        'Use Adaptive Loading'	=> well.adaptive_loading_check, # TRUE
        'Consensus Mode'	=> 'molecule', # (default to molecule do we need a custom field)
        'Same Barcodes on Both Ends of Sequence'	=> well.same_barcodes_on_both_ends_of_sequence # TRUE
      }
    end

    # Generate a hash of settings for the cell
    # Each key is a plate-well identifier and the value is a hash of settings for that particular cell
    def smrt_cell_settings
      wells = object.plates.flat_map(&:wells)
      wells = wells.each_with_object({}) do |well, hash|
        plate_well_name = "#{well.plate.plate_number}_#{well.position_leading_zero}"
        hash[plate_well_name] = well
      end

      # Iterate over each plate_well, accumulating the settings for each
      smrt_cells = wells.each_with_object({}) do |(plate_well, well), acc|
        acc[plate_well] = generate_smrt_cell_settings(well)
      end

      # transpose the settings to be grouped by key, not by plate_well
      smrt_cells.each_with_object({}) do |(plate_well, cell_data), result|
        cell_data.each do |(key, value)|
          result[key] ||= {}
          result[key].merge!({ plate_well => value })
        end
      end
    end

    def sample_settings
      # Bio Sample Name	Plate Well	Adapter	Adapter2	Pipeline Id	Analysis Name	Entry Points	Task Options
      # find_sample_name TOL-123	plate.plate_number + '_' +  well.position_leading_zero e.g. 1_A01	tag.group_id bc2001	tag.group_id bc2001	(not needed)	(not needed)	(not needed)	(not needed)
      # TOL-124	1_B01	bc2002	bc2001
      {}
    end

    def payload
      # Combine all elements into the final sample sheet
      sample_sheet = "[Run Settings]\n"

      # Start with the run settings
      sample_sheet += run_settings.map { |k, v| "#{k},#{v}" }.join("\n")

      # Add the cell settings
      sample_sheet += "\n[SMRT Cell Settings]"
      sample_sheet += ",#{plate_well_names.join(',')}\n"
      sample_sheet += smrt_cell_settings.map do |key, cells|
        "#{key}," + cells.values.join(',')
      end.join("\n")

      # Add the sample settings
      sample_sheet += "\n[Samples]\n"
      sample_sheet += sample_settings.map { |k, v| "#{k},#{v}" }.join("\n")

      sample_sheet
    end
  end
end
