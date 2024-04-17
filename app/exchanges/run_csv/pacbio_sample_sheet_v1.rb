# frozen_string_literal: true

# A class spefically for SMRT-Link v13 Sample Sheets, based on the PacbioSampleSheet class
# See https://www.pacb.com/wp-content/uploads/SMRT-Link-User-Guide-v13.1.pdf (page 31) for details.

module RunCsv
  # RunCsv::PacbioSampleSheetV1
  # Used to generate sample sheets specific to the PacBio pipeline (introduced in SMRT Link v13)
  class PacbioSampleSheetV1 < PacbioSampleSheet
    # Generate a hash of settings for the run
    def run_settings
      run = object # Pacbio::Run

      plate_data = run.plates.first(2).each_with_index.with_object({}) do |(plate, index), hash|
        hash["Plate #{index + 1}"] = plate&.sequencing_kit_box_barcode
      end

      {
        'Instrument Type' => run.system_name,
        'Run Name' =>	run.name,
        'Run Comments' =>	run.comments
      }.merge(plate_data).merge(
        { 'CSV Version' => 1 }
      )
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
        'Well Name'	=> well.used_aliquots.first.source.tube.barcode, # TRAC-2-7242
        'Library Type'	=> 'Standard', # (potentially new field otherwise just string)
        'Movie Acquisition Time (hours)'	=> well.movie_acquisition_time, # 24
        'Insert Size (bp)'	=> well.insert_size, # 500
        'Assign Data To Project'	=> 1, # (maybe we need to assign a run a project in traction)?
        'Library Concentration (pM)'	=> well.library_concentration, # 250
        'Include Base Kinetics'	=> evaluates_as_true?(well.include_base_kinetics),
        'Polymerase Kit'	=> well.polymerase_kit, # 032037102739100071224
        'Indexes'	=> well.barcode_set, # 244d96c6-f3b2-4997-5ae3-23ed33ab925f
        'Sample is indexed'	=> well.tagged?, # Set to True to Multiplex
        'Bio Sample Name' => well.tagged? ? nil : well.bio_sample_name,
        'Use Adaptive Loading'	=> well.adaptive_loading_check, # TRUE
        'Consensus Mode'	=> 'molecule', # (default to molecule do we need a custom field)
        'Same Barcodes on Both Ends of Sequence'	=> well.same_barcodes_on_both_ends_of_sequence
      }
    end

    # Generate a hash of settings for the cell
    def generate_wells
      object.plates.flat_map(&:wells).each_with_object({}) do |well, hash|
        plate_well_name = "#{well.plate.plate_number}_#{well.position_leading_zero}"
        hash[plate_well_name] = well
      end
    end

    def generate_smrt_cells(wells)
      wells.each_with_object({}) do |(plate_well, well), acc|
        acc[plate_well] = generate_smrt_cell_settings(well)
      end
    end

    def transpose_smrt_cells(smrt_cells)
      smrt_cells.each_with_object({}) do |(plate_well, cell_data), result|
        cell_data.each do |(key, value)|
          result[key] ||= {}
          result[key].merge!({ plate_well => value })
        end
      end
    end

    # Each key is a plate-well identifier and the value is a hash of settings for a particular cell
    def smrt_cell_settings
      wells = generate_wells
      smrt_cells = generate_smrt_cells(wells)
      transpose_smrt_cells(smrt_cells)
    end

    def sample_data(well, sample)
      [
        sample.bio_sample_name,
        well.plate_well_position,
        sample.adapter, # left adapter
        sample.adapter  # right adapter
      ]
    end

    # Generate a CSV of samples
    def samples_csv
      headers = ['Bio Sample Name', 'Plate Well', 'Adapter', 'Adapter2']
      CSV.generate do |csv|
        csv << headers
        object.sorted_wells.each do |well|
          well.aliquots_to_show_per_row&.each do |sample|
            csv << sample_data(well, sample)
          end
        end
      end
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
      sample_sheet += samples_csv

      # Replace Trues and Falses with upper case versions
      sample_sheet.gsub!('true', 'TRUE')
      sample_sheet.gsub!('false', 'FALSE')

      sample_sheet
    end

    private

    def evaluates_as_true?(value)
      value.downcase == 'true'
    end
  end
end
