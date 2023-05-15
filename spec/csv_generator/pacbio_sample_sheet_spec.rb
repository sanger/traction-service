# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PacbioSampleSheet, type: :model do
  let!(:version10) { create(:pacbio_smrt_link_version, name: 'v10', default: true) }

  describe '#generate' do
    subject(:csv_string) { csv.generate }

    let!(:plate)       { create(:pacbio_plate) }
    let!(:run)         { create(:pacbio_run, smrt_link_version: version10, plates: [plate]) }
    let!(:parsed_csv)  { CSV.parse(csv_string) }
    let!(:csv)         { described_class.new(run:, configuration: Pipelines.pacbio.sample_sheet.by_version(run.smrt_link_version.name)) }

    context 'when the libraries are tagged' do
      let!(:well1) do
        create(:pacbio_well_with_pools, pre_extension_time: 2, generate_hifi: 'In SMRT Link',
                                        ccs_analysis_output: 'Yes')
      end
      let!(:well2) do
        create(:pacbio_well_with_pools, pre_extension_time: 2, generate_hifi: 'In SMRT Link',
                                        ccs_analysis_output: 'No')
      end
      let(:plate) { create(:pacbio_plate, wells: [well1, well2]) }

      it 'must return a csv string' do
        expect(csv_string.class).to eq String
      end

      it 'must have the correct headers' do
        headers = parsed_csv[0]

        expected_headers = Pipelines.pacbio.sample_sheet.columns.map(&:first)
        expect(headers).to eq(expected_headers)
      end

      it 'must have the correct well header rows' do
        well_data_1 = parsed_csv[1]
        well_data_2 = parsed_csv[7]

        expect(well_data_1).to eq([
          well1.plate.run.system_name,
          well1.plate.run.name,
          'true',
          well1.position,
          well1.pool_barcode,
          well1.movie_time.to_s,
          well1.insert_size.to_s,
          well1.template_prep_kit_box_barcode,
          well1.binding_kit_box_barcode,
          well1.plate.run.sequencing_kit_box_barcode,
          well1.on_plate_loading_concentration.to_s,
          well1.plate.run.dna_control_complex_box_barcode,
          well1.plate.run.comments,
          well1.show_row_per_sample?.to_s,
          '',
          well1.barcode_set,
          well1.same_barcodes_on_both_ends_of_sequence.to_s,
          '',
          well1.automation_parameters,
          well1.generate_hifi,
          well1.ccs_analysis_output,
          well1.loading_target_p1_plus_p2.to_s,
          well1.adaptive_loading_check.to_s
        ])

        expect(well_data_2).to eq([
          well2.plate.run.system_name,
          well2.plate.run.name,
          'true',
          well2.position,
          well2.pool_barcode,
          well2.movie_time.to_s,
          well2.insert_size.to_s,
          well2.template_prep_kit_box_barcode,
          well2.binding_kit_box_barcode,
          well2.plate.run.sequencing_kit_box_barcode,
          well2.on_plate_loading_concentration.to_s,
          well2.plate.run.dna_control_complex_box_barcode,
          well2.plate.run.comments,
          well2.show_row_per_sample?.to_s,
          '',
          well2.barcode_set,
          well2.same_barcodes_on_both_ends_of_sequence.to_s,
          '',
          well2.automation_parameters,
          well2.generate_hifi,
          well2.ccs_analysis_output,
          well2.loading_target_p1_plus_p2.to_s,
          well2.adaptive_loading_check.to_s
        ])
      end

      it 'must have the correct sample rows' do
        sample_data_1 = parsed_csv[2]
        sample_data_2 = parsed_csv[8]

        expect(sample_data_1).to eq([
          '',
          '',
          'false',
          well1.position,
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          well1.libraries.first.barcode_name,
          '',
          '',
          well1.libraries.first.request.sample_name,
          '',
          '',
          '',
          '',
          ''
        ])

        expect(sample_data_2).to eq([
          '',
          '',
          'false',
          well2.position,
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          well2.libraries.first.barcode_name,
          '',
          '',
          well2.libraries.first.request.sample_name,
          '',
          '',
          '',
          '',
          ''
        ])
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
      let(:plate) { create(:pacbio_plate, wells: [well1, well2]) }

      it 'must return a csv string' do
        expect(csv_string).to be_a String
      end

      it 'must have the correct headers' do
        headers = parsed_csv[0]

        expected_headers = Pipelines.pacbio.sample_sheet.columns.map(&:first)
        expect(headers).to eq(expected_headers)
      end

      it 'must have the correct well header rows' do
        well_data_1 = parsed_csv[1]
        well_data_2 = parsed_csv[2]

        expect(well_data_1).to eq([
          well1.plate.run.system_name,
          well1.plate.run.name,
          'true',
          well1.position,
          well1.pool_barcode,
          well1.movie_time.to_s,
          well1.insert_size.to_s,
          well1.template_prep_kit_box_barcode,
          well1.binding_kit_box_barcode,
          well1.plate.run.sequencing_kit_box_barcode,
          well1.on_plate_loading_concentration.to_s,
          well1.plate.run.dna_control_complex_box_barcode,
          well1.plate.run.comments,
          well1.sample_is_barcoded.to_s,
          '',
          well1.barcode_set,
          well1.same_barcodes_on_both_ends_of_sequence.to_s,
          well1.find_sample_name,
          well1.automation_parameters,
          well1.generate_hifi,
          well1.ccs_analysis_output,
          well1.loading_target_p1_plus_p2.to_s,
          well1.adaptive_loading_check.to_s
        ])

        expect(well_data_2).to eq([
          well2.plate.run.system_name,
          well2.plate.run.name,
          'true',
          well2.position,
          well2.pool_barcode,
          well2.movie_time.to_s,
          well2.insert_size.to_s,
          well2.template_prep_kit_box_barcode,
          well2.binding_kit_box_barcode,
          well2.plate.run.sequencing_kit_box_barcode,
          well2.on_plate_loading_concentration.to_s,
          well2.plate.run.dna_control_complex_box_barcode,
          well2.plate.run.comments,
          well2.sample_is_barcoded.to_s,
          '',
          well2.barcode_set,
          well2.same_barcodes_on_both_ends_of_sequence.to_s,
          well2.find_sample_name,
          well2.automation_parameters,
          well2.generate_hifi,
          well2.ccs_analysis_output,
          well2.loading_target_p1_plus_p2.to_s,
          well2.adaptive_loading_check.to_s
        ])
      end

      it 'must not have sample rows' do
        expect(parsed_csv.size).to eq 3
      end
    end

    context 'with lots of wells in unpredictable orders' do
      let(:pool1)   { create_list(:pacbio_pool, 1, :untagged) }
      let(:pool2)   { create_list(:pacbio_pool, 1, :untagged) }
      let(:pool3)   { create_list(:pacbio_pool, 1, :untagged) }
      let(:well1)   { create(:pacbio_well, pools: pool1, row: 'A', column: 10) }
      let(:well2)   { create(:pacbio_well, pools: pool2, row: 'A', column: 5) }
      let(:well3)   { create(:pacbio_well, pools: pool3, row: 'B', column: 1) }
      let(:plate)   { create(:pacbio_plate, wells: [well1, well2, well3]) }

      it 'sorts the wells by column' do
        sorted_well_positions = parsed_csv[1..].pluck(3)
        expect(sorted_well_positions).to eq(%w[B01 A05 A10])
      end
    end
  end
end
