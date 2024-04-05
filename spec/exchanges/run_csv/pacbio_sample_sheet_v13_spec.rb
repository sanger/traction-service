# frozen_string_literal: true

require 'rails_helper'

# import parser to assist with testing
require_relative '../../../app/exchanges/run_csv/pacbio_sample_sheet_v13_parser'

# See additional sample sheet specs at 'spec/pipelines/pacbio/sample_sheet_spec.rb'

RSpec.describe RunCsv::PacbioSampleSheetV13, type: :model do
  describe '#payload' do
    subject(:sample_sheet_string) { sample_sheet.payload }

    let(:run)           { create(:pacbio_revio_run, smrt_link_version:) }
    let(:sample_sheet)  { described_class.new(object: run, configuration:) }
    let(:configuration) { Pipelines.pacbio.sample_sheet.by_version(run.smrt_link_version.name) }
    let(:parsed_sample_sheet) { RunCsv::PacbioSampleSheetV13Parser.new.parse(sample_sheet_string) }

    context 'v13_revio' do
      let(:smrt_link_version) { create(:pacbio_smrt_link_version_default, name: 'v13_revio') }

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
            'Well Name' => well.pools.first.tube.barcode,
            'Library Type' => 'Standard',
            'Movie Acquisition Time (hours)' => well.movie_acquisition_time.to_s,
            'Insert Size (bp)' => well.insert_size.to_s,
            'Assign Data To Project' => '1',
            'Library Concentration (pM)' => well.library_concentration.to_s,
            'Include Base Kinetics' => well.include_base_kinetics.to_s,
            'Polymerase Kit' => well.polymerase_kit,
            'Indexes' => well.barcode_set,
            'Sample is indexed' => well.collection?.to_s,
            'Use Adaptive Loading' => well.adaptive_loading_check.to_s,
            'Consensus Mode' => 'molecule',
            'Same Barcodes on Both Ends of Sequence' => well.same_barcodes_on_both_ends_of_sequence.to_s
          }
          expect(smrt_cell_settings[plate_well_name]).to eq(expected_settings)
        end
      end

      it 'must return a csv string' do
        expect(sample_sheet_string.class).to eq String
      end

      context 'when the libraries are tagged' do
        let(:well1) do
          create(
            :pacbio_well_with_pools,
            pre_extension_time: 2,
            generate_hifi: 'In SMRT Link',
            ccs_analysis_output: 'Yes'
          )
        end
        let(:well2) do
          create(
            :pacbio_well_with_pools,
            pre_extension_time: 2,
            generate_hifi: 'In SMRT Link',
            ccs_analysis_output: 'No'
          )
        end
        let(:wells) { [well1, well2] }

        it 'must have the correct headers' do
          headers = parsed_sample_sheet[0]

          expected_headers = configuration.column_order
          expect(headers).to eq(expected_headers)
        end

        it 'must have the correct well header rows' do
          well_data_1 = parsed_sample_sheet[1]
          well_data_2 = parsed_sample_sheet[7]
          #  iterate through the wells under test
          well_expectations = [
            [well_data_1, well1],
            [well_data_2, well2]
          ]
          well_expectations.each do |well_data, well|
            expect(well_data).to eq([
              'Standard', # library type
              '1', # reagent plate
              well.plate.sequencing_kit_box_barcode,
              nil, # plate 2: sequencing_kit_box_barcode
              well.plate.run.name,
              well.plate.run.system_name,
              well.plate.run.comments,
              'true', # well.collection?
              well.position_leading_zero,
              well.tube_barcode,
              well.movie_acquisition_time.to_s,
              well.include_base_kinetics.to_s,
              well.library_concentration.to_s,
              well.polymerase_kit,
              well.automation_parameters,
              well.barcode_set,
              nil, # barcode name - does not apply
              nil, # sample name - does not apply
              well.insert_size.to_s,
              'false' # Default for Use Adaptive Loading
            ])
          end
        end

        it 'must have the correct sample rows' do
          # Note the increment in the parsed_sample_sheet index
          sample_data_1 = parsed_sample_sheet[2]
          sample_data_2 = parsed_sample_sheet[8]

          #  iterate through the samples under test
          sample_expectations = [
            [sample_data_1, well1],
            [sample_data_2, well2]
          ]
          sample_expectations.each do |sample_data, well|
            expect(sample_data).to eq([
              nil,
              '1', # reagent plate
              nil,
              nil,
              nil,
              nil,
              nil,
              'false', # aliquot.collection?
              well.position,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              well.base_used_aliquots.first.barcode_name,
              well.base_used_aliquots.first.bio_sample_name,
              nil,
              nil
            ])
          end
        end
      end

      context 'when the libraries are untagged' do
        let(:pool1)   { create_list(:pacbio_pool, 1, :untagged) }
        let(:pool2)   { create_list(:pacbio_pool, 1, :untagged) }
        let(:well1)   do
          create(:pacbio_well, pre_extension_time: 2, generate_hifi: 'Do Not Generate',
                               ccs_analysis_output: 'Yes', pools: pool1)
        end
        let(:well2) do
          create(:pacbio_well, generate_hifi: 'On Instrument', ccs_analysis_output: 'No',
                               pools: pool2)
        end
        let(:wells) { [well1, well2] }

        it 'must have the correct headers' do
          headers = parsed_sample_sheet[0]

          expected_headers = configuration.column_order
          expect(headers).to eq(expected_headers)
        end

        it 'must have the correct well header rows' do
          well_data_1 = parsed_sample_sheet[1]
          well_data_2 = parsed_sample_sheet[2]
          #  iterate through the wells under test
          well_expectations = [
            [well_data_1, well1],
            [well_data_2, well2]
          ]
          well_expectations.each do |well_data, well|
            expect(well_data).to eq([
              'Standard', # library type
              '1', # reagent plate
              well.plate.sequencing_kit_box_barcode,
              nil, # plate 2: sequencing_kit_box_barcode
              well.plate.run.name,
              well.plate.run.system_name,
              well.plate.run.comments,
              'true', # well.collection?
              well.position_leading_zero,
              well.tube_barcode,
              well.movie_acquisition_time.to_s,
              well.include_base_kinetics.to_s,
              well.library_concentration.to_s,
              well.polymerase_kit,
              well.automation_parameters,
              well.barcode_set,
              nil, # barcode name - does not apply
              well.bio_sample_name,
              well.insert_size.to_s,
              'false' # Default for Use Adaptive Loading
            ])
          end
        end

        it 'must not have sample rows' do
          expect(parsed_sample_sheet.size).to eq 3
        end
      end

      context 'with lots of wells in unpredictable orders' do
        let(:pool1) { create_list(:pacbio_pool, 1, :untagged) }
        let(:pool2) { create_list(:pacbio_pool, 1, :untagged) }
        let(:pool3) { create_list(:pacbio_pool, 1, :untagged) }
        let(:well1) { create(:pacbio_well, pools: pool1, row: 'A', column: 10) }
        let(:well2) { create(:pacbio_well, pools: pool2, row: 'A', column: 5) }
        let(:well3) { create(:pacbio_well, pools: pool3, row: 'B', column: 1) }
        let(:wells) { [well1, well2, well3] }

        it 'sorts the wells by column' do
          sorted_well_positions = parsed_sample_sheet[1..].pluck(8)
          expect(sorted_well_positions).to eq(%w[B01 A05 A10])
        end
      end
    end
  end
end
