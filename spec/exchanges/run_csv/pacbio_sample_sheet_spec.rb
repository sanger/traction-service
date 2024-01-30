# frozen_string_literal: true

require 'rails_helper'

# See additional sample sheet specs at 'spec/pipelines/pacbio/sample_sheet_spec.rb'

RSpec.describe RunCsv::PacbioSampleSheet, type: :model do
  describe '#payload' do
    subject(:csv_string) { csv.payload }

    let(:plate)       { build(:pacbio_plate, wells:, plate_number: 1) }
    let(:run)         { create(:pacbio_run, smrt_link_version:, plates: [plate]) }
    let(:parsed_csv)  { CSV.parse(csv_string) }
    let(:csv)         { described_class.new(object: run, configuration:) }
    let(:configuration) { Pipelines.pacbio.sample_sheet.by_version(run.smrt_link_version.name) }

    context 'v12_revio' do
      let(:smrt_link_version) { create(:pacbio_smrt_link_version_default, name: 'v12_revio') }

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

        it 'must return a csv string' do
          expect(csv_string.class).to eq String
        end

        it 'must have the correct headers' do
          headers = parsed_csv[0]

          expected_headers = configuration.column_order
          expect(headers).to eq(expected_headers)
        end

        it 'must have the correct well header rows' do
          well_data_1 = parsed_csv[1]
          well_data_2 = parsed_csv[7]
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
              well.pool_barcode,
              well.movie_acquisition_time.to_s,
              well.include_base_kinetics.to_s,
              well.library_concentration.to_s,
              well.polymerase_kit,
              well.automation_parameters,
              well.barcode_set,
              nil, # barcode name - does not apply
              nil # sample name - does not apply
            ])
          end
        end

        it 'must have the correct sample rows' do
          # Note the increment in the parsed_csv index
          sample_data_1 = parsed_csv[2]
          sample_data_2 = parsed_csv[8]

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
              'false', # well.collection?
              well.position,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              well.libraries.first.barcode_name,
              well.libraries.first.request.sample_name
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

        it 'must return a csv string' do
          expect(csv_string).to be_a String
        end

        it 'must have the correct headers' do
          headers = parsed_csv[0]

          expected_headers = configuration.column_order
          expect(headers).to eq(expected_headers)
        end

        it 'must have the correct well header rows' do
          well_data_1 = parsed_csv[1]
          well_data_2 = parsed_csv[2]
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
              well.pool_barcode,
              well.movie_acquisition_time.to_s,
              well.include_base_kinetics.to_s,
              well.library_concentration.to_s,
              well.polymerase_kit,
              well.automation_parameters,
              well.barcode_set,
              nil, # barcode name - does not apply
              well.find_sample_name
            ])
          end
        end

        it 'must not have sample rows' do
          expect(parsed_csv.size).to eq 3
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
          sorted_well_positions = parsed_csv[1..].pluck(8)
          expect(sorted_well_positions).to eq(%w[B01 A05 A10])
        end
      end
    end

    context 'v12_sequel_iie' do
      let(:smrt_link_version) { create(:pacbio_smrt_link_version, name: 'v12_sequel_iie', default: true) }

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

        it 'must return a csv string' do
          expect(csv_string.class).to eq String
        end

        it 'must have the correct headers' do
          headers = parsed_csv[0]

          expected_headers = configuration.column_order
          expect(headers).to eq(expected_headers)
        end

        it 'must have the correct well header rows' do
          well_data_1 = parsed_csv[1]
          well_data_2 = parsed_csv[7]
          #  iterate through the wells under test
          well_expectations = [
            [well_data_1, well1],
            [well_data_2, well2]
          ]
          well_expectations.each do |well_data, well|
            expect(well_data).to eq([
              well.plate.run.system_name,
              well.plate.run.name,
              'true', # well.collection?
              well.position,
              well.pool_barcode,
              well.movie_time.to_s,
              well.insert_size.to_s,
              well.template_prep_kit_box_barcode,
              well.binding_kit_box_barcode,
              well.plate.sequencing_kit_box_barcode,
              well.on_plate_loading_concentration.to_s,
              well.plate.run.dna_control_complex_box_barcode,
              well.plate.run.comments,
              well.show_row_per_sample?.to_s,
              nil, # barcode name - does not apply
              well.barcode_set,
              well.same_barcodes_on_both_ends_of_sequence.to_s,
              nil, # sample name - does not apply
              well.automation_parameters,
              well.ccs_analysis_output_include_kinetics_information,
              well.loading_target_p1_plus_p2.to_s,
              well.adaptive_loading_check.to_s,
              well.ccs_analysis_output_include_low_quality_reads,
              well.include_fivemc_calls_in_cpg_motifs,
              well.demultiplex_barcodes
            ])
          end
        end

        it 'must have the correct sample rows' do
          # Note the increment in the parsed_csv index
          sample_data_1 = parsed_csv[2]
          sample_data_2 = parsed_csv[8]

          #  iterate through the samples under test
          sample_expectations = [
            [sample_data_1, well1],
            [sample_data_2, well2]
          ]
          sample_expectations.each do |sample_data, well|
            expect(sample_data).to eq([
              nil,
              nil,
              'false', # well.collection?
              well.position,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              well.libraries.first.barcode_name,
              nil,
              nil,
              well.libraries.first.request.sample_name,
              nil,
              nil,
              nil,
              nil,
              nil,
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

        it 'must return a csv string' do
          expect(csv_string).to be_a String
        end

        it 'must have the correct headers' do
          headers = parsed_csv[0]

          expected_headers = configuration.column_order
          expect(headers).to eq(expected_headers)
        end

        it 'must have the correct well header rows' do
          well_data_1 = parsed_csv[1]
          well_data_2 = parsed_csv[2]
          #  iterate through the wells under test
          well_expectations = [
            [well_data_1, well1],
            [well_data_2, well2]
          ]
          well_expectations.each do |well_data, well|
            expect(well_data).to eq([
              well.plate.run.system_name,
              well.plate.run.name,
              'true', # well.collection?
              well.position,
              well.pool_barcode,
              well.movie_time.to_s,
              well.insert_size.to_s,
              well.template_prep_kit_box_barcode,
              well.binding_kit_box_barcode,
              well.plate.sequencing_kit_box_barcode,
              well.on_plate_loading_concentration.to_s,
              well.plate.run.dna_control_complex_box_barcode,
              well.plate.run.comments,
              well.sample_is_barcoded.to_s,
              nil, # barcode name - does not apply
              well.barcode_set,
              well.same_barcodes_on_both_ends_of_sequence.to_s,
              well.find_sample_name,
              well.automation_parameters,
              well.ccs_analysis_output_include_kinetics_information,
              well.loading_target_p1_plus_p2.to_s,
              well.adaptive_loading_check.to_s,
              well.ccs_analysis_output_include_low_quality_reads,
              well.include_fivemc_calls_in_cpg_motifs,
              well.demultiplex_barcodes
            ])
          end
        end

        it 'must not have sample rows' do
          expect(parsed_csv.size).to eq 3
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
          sorted_well_positions = parsed_csv[1..].pluck(3)
          expect(sorted_well_positions).to eq(%w[B01 A05 A10])
        end
      end
    end

    context 'v13_revio' do
      let(:smrt_link_version) { create(:pacbio_smrt_link_version_default, name: 'v13_revio') }

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

        it 'must return a csv string' do
          expect(csv_string.class).to eq String
        end

        it 'must have the correct headers' do
          headers = parsed_csv[0]

          expected_headers = configuration.column_order
          expect(headers).to eq(expected_headers)
        end

        it 'must have the correct well header rows' do
          well_data_1 = parsed_csv[1]
          well_data_2 = parsed_csv[7]
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
              well.pool_barcode,
              well.movie_acquisition_time.to_s,
              well.include_base_kinetics.to_s,
              well.library_concentration.to_s,
              well.polymerase_kit,
              well.automation_parameters,
              well.barcode_set,
              nil, # barcode name - does not apply
              nil, # sample name - does not apply
              well.insert_size.to_s
            ])
          end
        end

        it 'must have the correct sample rows' do
          # Note the increment in the parsed_csv index
          sample_data_1 = parsed_csv[2]
          sample_data_2 = parsed_csv[8]

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
              'false', # well.collection?
              well.position,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              well.libraries.first.barcode_name,
              well.libraries.first.request.sample_name,
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

        it 'must return a csv string' do
          expect(csv_string).to be_a String
        end

        it 'must have the correct headers' do
          headers = parsed_csv[0]

          expected_headers = configuration.column_order
          expect(headers).to eq(expected_headers)
        end

        it 'must have the correct well header rows' do
          well_data_1 = parsed_csv[1]
          well_data_2 = parsed_csv[2]
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
              well.pool_barcode,
              well.movie_acquisition_time.to_s,
              well.include_base_kinetics.to_s,
              well.library_concentration.to_s,
              well.polymerase_kit,
              well.automation_parameters,
              well.barcode_set,
              nil, # barcode name - does not apply
              well.find_sample_name,
              well.insert_size.to_s
            ])
          end
        end

        it 'must not have sample rows' do
          expect(parsed_csv.size).to eq 3
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
          sorted_well_positions = parsed_csv[1..].pluck(8)
          expect(sorted_well_positions).to eq(%w[B01 A05 A10])
        end
      end
    end
  end
end
