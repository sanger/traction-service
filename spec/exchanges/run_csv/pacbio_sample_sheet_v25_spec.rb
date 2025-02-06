# frozen_string_literal: true

require 'rails_helper'

# import parser to assist with testing
# huh? what is this? If we need a parser to parse the sample sheet probably needs a refactor
require_relative '../../support/parsers/pacbio_sample_sheet_parser'

RSpec.describe RunCsv::PacbioSampleSheetV25, type: :model do
  before do
    # Create a default smrt link version
    create(:pacbio_smrt_link_version, name: 'v25_1_revio', default: true)
  end

  describe '#payload' do
    subject(:sample_sheet_string) { sample_sheet.payload }

    let(:run)           { create(:pacbio_revio_run) }
    let(:sample_sheet)  { described_class.new(object: run, configuration:) }
    let(:configuration) { Pipelines.pacbio.sample_sheet.by_version(run.smrt_link_version.name) }
    let(:parsed_sample_sheet) { Parsers::PacbioSampleSheetParser.new.parse(sample_sheet_string) }

    context 'v25_1_revio' do
      it 'must return a string' do
        expect(sample_sheet_string.class).to eq String
      end

      it 'must have the three required sections' do
        expect(sample_sheet_string).to include('[Run Settings]')
        expect(sample_sheet_string).to include('[SMRT Cell Settings]')
        expect(sample_sheet_string).to include('[Samples]')
      end

      it 'must have the three required sections in the correct order' do
        run_settings_index = sample_sheet_string.index('[Run Settings]')
        cell_settings_index = sample_sheet_string.index('[SMRT Cell Settings]')
        samples_index = sample_sheet_string.index('[Samples]')

        expect(run_settings_index).to be < cell_settings_index
        expect(cell_settings_index).to be < samples_index
      end

      it 'must have the correct run settings' do
        expect(parsed_sample_sheet['Run Settings']).to eq(
          {
            'Instrument Type' => 'Revio',
            'Run Name' => run.name,
            'Run Comments' => run.comments,
            'Plate 1' => run.plates[0].sequencing_kit_box_barcode,
            'Plate 2' => run.plates[1].sequencing_kit_box_barcode,
            'CSV Version' => '1'
          }
        )
      end

      it 'must have the cells used listed on the same line as the section header' do
        # get the line from sample_sheet_string containing [SMRT Cell Settings]
        smrt_cell_settings_line = sample_sheet_string.lines.find { |line| line.include?('[SMRT Cell Settings]') }.strip
        expect(smrt_cell_settings_line).to eq('[SMRT Cell Settings],1_A01,1_B01,2_A01')
      end

      it 'must have the correct SMRT cell settings' do
        smrt_cell_settings = parsed_sample_sheet['SMRT Cell Settings']

        # create a hash of plate_well_name => well for easy comparison
        plate_wells = run.plates.flat_map(&:wells).each_with_object({}) do |well, hash|
          plate_well_name = "#{well.plate.plate_number}_#{well.position_leading_zero}"
          hash[plate_well_name] = well
        end

        # confirm that the wells are as expected
        plate_well_names = plate_wells.keys
        expect(plate_well_names).to contain_exactly('1_A01', '1_B01', '2_A01')
        expect(smrt_cell_settings.keys).to match_array(plate_well_names)

        plate_well_names.each do |plate_well_name|
          well = plate_wells[plate_well_name]
          expected_settings = {
            # for all wells
            'Well Name' => well.used_aliquots.first.source.tube.barcode,
            'Library Type' => 'Standard',
            'Movie Acquisition Time (hours)' => well.movie_acquisition_time.to_s,
            'Insert Size (bp)' => well.insert_size.to_s,
            'Assign Data To Project' => '1',
            'Library Concentration (pM)' => well.library_concentration.to_s,
            'Include Base Kinetics' => well.include_base_kinetics.downcase == 'true', # is a string
            'Use Adaptive Loading' => well.use_adaptive_loading.downcase == 'true',
            'Consensus Mode' => 'molecule',
            'Full Resolution Base Qual' => well.full_resolution_base_qual == 'true',

            # specific to tagged wells
            'Bio Sample Name' => '',
            'Sample is indexed' => true,
            'Indexes' => well.barcode_set,
            'Same Barcodes on Both Ends of Sequence' => true
          }

          expect(smrt_cell_settings[plate_well_name]).to eq(expected_settings)
        end
      end

      context 'when the libraries are tagged' do
        let(:well1) do
          create(
            :pacbio_well,
            pre_extension_time: 2,
            generate_hifi: 'In SMRT Link',
            ccs_analysis_output: 'Yes',
            row: 'A',
            column: 1
          )
        end
        let(:well2) do
          create(
            :pacbio_well,
            pre_extension_time: 2,
            generate_hifi: 'In SMRT Link',
            ccs_analysis_output: 'No',
            row: 'A',
            column: 1
          )
        end
        let(:well3) do
          create(
            :pacbio_well,
            pre_extension_time: 2,
            generate_hifi: 'In SMRT Link',
            ccs_analysis_output: 'No',
            row: 'B',
            column: 1
          )
        end
        let(:plate1_wells)   { [well1] }
        let(:plate2_wells)   { [well2, well3] }
        let(:plate1)  { build(:pacbio_plate, wells: plate1_wells, plate_number: 1) }
        let(:plate2)  { build(:pacbio_plate, wells: plate2_wells, plate_number: 2) }
        let(:run)     { create(:pacbio_revio_run, plates: [plate1, plate2]) }

        it 'must have the correct headers' do
          # get the line from sample_sheet_string after the one containing [Samples]
          sample_sheet_lines = sample_sheet_string.lines
          samples_section_index = sample_sheet_lines.find_index { |line| line.include?('[Samples]') }
          headers_line = sample_sheet_lines[samples_section_index + 1]
          headers = headers_line.strip.split(',')
          expected_headers = ['Bio Sample Name', 'Plate Well', 'Adapter', 'Adapter2']
          expect(headers).to eq(expected_headers)
        end

        it 'must have the correct sample rows' do
          # 5 pools per well
          sample_data_1 = parsed_sample_sheet['Samples'][0]
          sample_data_2 = parsed_sample_sheet['Samples'][1 * 5]
          sample_data_3 = parsed_sample_sheet['Samples'][2 * 5]

          #  iterate through the samples under test
          sample_expectations = [
            [sample_data_1, well1],
            [sample_data_2, well2],
            [sample_data_3, well3]
          ]
          sample_expectations.each do |sample_data, well|
            expect(sample_data).to eq(
              {
                'Bio Sample Name' => well.base_used_aliquots.first.bio_sample_name,
                'Plate Well' => well.plate_well_position,
                'Adapter' => well.base_used_aliquots.first.tag.group_id,
                'Adapter2' => well.base_used_aliquots.first.tag.group_id
              }
            )
          end
        end
      end

      context 'when the libraries are untagged' do
        let(:pool1)   { create_list(:pacbio_pool, 1, :untagged) }
        let(:pool2)   { create_list(:pacbio_pool, 1, :untagged) }
        let(:pool3)   { create_list(:pacbio_pool, 1, :untagged) }
        let(:well1) do
          create(
            :pacbio_well,
            pre_extension_time: 2,
            generate_hifi: 'In SMRT Link',
            ccs_analysis_output: 'Yes',
            pools: pool1, # untagged pool
            row: 'A',
            column: 1
          )
        end
        let(:well2) do
          create(
            :pacbio_well,
            pre_extension_time: 2,
            generate_hifi: 'In SMRT Link',
            ccs_analysis_output: 'No',
            pools: pool2, # untagged pool
            row: 'A',
            column: 1
          )
        end
        let(:well3) do
          create(
            :pacbio_well,
            pre_extension_time: 2,
            generate_hifi: 'In SMRT Link',
            ccs_analysis_output: 'No',
            pools: pool3, # untagged pool
            row: 'B',
            column: 1
          )
        end
        let(:plate1_wells)   { [well1] }
        let(:plate2_wells)   { [well2, well3] }
        let(:plate1)  { build(:pacbio_plate, wells: plate1_wells, plate_number: 1) }
        let(:plate2)  { build(:pacbio_plate, wells: plate2_wells, plate_number: 2) }
        let(:run)     { create(:pacbio_revio_run, plates: [plate1, plate2]) }

        it 'must have the correct headers' do
          # get the line from sample_sheet_string after the one containing [Samples]
          sample_sheet_lines = sample_sheet_string.lines
          samples_section_index = sample_sheet_lines.find_index { |line| line.include?('[Samples]') }
          headers_line = sample_sheet_lines[samples_section_index + 1]
          headers = headers_line.strip.split(',')
          expected_headers = ['Bio Sample Name', 'Plate Well', 'Adapter', 'Adapter2']
          expect(headers).to eq(expected_headers)
        end

        it 'must have the wells added to the SMRT Cell Settings section' do
          smrt_cell_settings = parsed_sample_sheet['SMRT Cell Settings']

          # create a hash of plate_well_name => well for easy comparison
          plate_wells = run.plates.flat_map(&:wells).each_with_object({}) do |well, hash|
            plate_well_name = "#{well.plate.plate_number}_#{well.position_leading_zero}"
            hash[plate_well_name] = well
          end

          # confirm that the wells are as expected
          plate_well_names = plate_wells.keys
          expect(plate_well_names).to contain_exactly('1_A01', '2_A01', '2_B01')
          expect(smrt_cell_settings.keys).to match_array(plate_well_names)

          #  iterate through the wells under test
          plate_well_names.each do |plate_well_name|
            well_data = smrt_cell_settings[plate_well_name]
            well = plate_wells[plate_well_name]

            expect(well_data).to eq(
              # for all wells
              'Well Name' => well.used_aliquots.first.source.tube.barcode,
              'Library Type' => 'Standard',
              'Movie Acquisition Time (hours)' => well.movie_acquisition_time.to_s,
              'Insert Size (bp)' => well.insert_size.to_s,
              'Assign Data To Project' => '1',
              'Library Concentration (pM)' => well.library_concentration.to_s,
              'Include Base Kinetics' => well.include_base_kinetics.downcase == 'true', # is a string
              'Use Adaptive Loading' => well.use_adaptive_loading.downcase == 'true',
              'Consensus Mode' => 'molecule',
              'Full Resolution Base Qual' => well.full_resolution_base_qual == 'true',

              # specific to untagged wells
              'Bio Sample Name' => well.formatted_bio_sample_name,
              'Sample is indexed' => false,
              'Indexes' => '', # well.barcode_set
              'Same Barcodes on Both Ends of Sequence' => '' # well.same_barcodes_on_both_ends_of_sequence.to_s
            )
          end
        end

        it 'must not have sample rows' do
          expect(parsed_sample_sheet['Samples']).to be_empty
        end
      end
    end
  end
end
