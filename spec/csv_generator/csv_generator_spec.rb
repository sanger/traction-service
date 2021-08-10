require "rails_helper"

RSpec.describe CsvGenerator, type: :model do
  after(:each) { File.delete('sample_sheet.csv') if File.exists?('sample_sheet.csv') }

  context '#generate_sample_sheet' do
    let(:well1)   { create(:pacbio_well_with_pools, pre_extension_time: 2, generate_hifi: 'In SMRT Link', ccs_analysis_output: 'Yes') }
    let(:well2)   { create(:pacbio_well_with_pools, pre_extension_time: 2, generate_hifi: 'In SMRT Link', ccs_analysis_output: 'No') }
    let(:plate)   { create(:pacbio_plate, wells: [well1, well2]) }
    let(:run)     { create(:pacbio_run, plate: plate) }
    let(:csv)     { ::CsvGenerator.new(run: run, configuration: Pipelines.pacbio.sample_sheet) }

    it 'check validity' do
      well = create(:pacbio_well)
      well.pools << create_list(:pacbio_pool, 5)
      expect(well).to be_valid
    end

    it 'must return a csv string' do
      csv_string = csv.generate_sample_sheet
      expect(csv_string.class).to eq String
    end

    it 'must have the correct headers' do
      csv_string = csv.generate_sample_sheet
      headers = CSV.parse(csv_string)[0]

      expected_headers = Pipelines.pacbio.sample_sheet.columns.map(&:first)
      expect(headers).to eq(expected_headers)
    end

    it 'must have the correct well header rows' do
      csv_string = csv.generate_sample_sheet
      array_of_rows = CSV.parse(csv_string)

      well_data_1 = array_of_rows[1]
      well_data_2 = array_of_rows[7]

      expect(well_data_1).to eq([
        well1.plate.run.system_name,
        well1.plate.run.name,
        'true',
        well1.position,
        well1.find_pool_barcode,
        well1.movie_time.to_s,
        well1.insert_size.to_s,
        well1.template_prep_kit_box_barcode,
        well1.binding_kit_box_barcode,
        well1.plate.run.sequencing_kit_box_barcode,
        well1.on_plate_loading_concentration.to_s,
        well1.plate.run.dna_control_complex_box_barcode,
        well1.plate.run.comments,
        well1.all_libraries_tagged.to_s,
        '',
        well1.barcode_set,
        well1.same_barcodes_on_both_ends_of_sequence.to_s,
        '',
        well1.automation_parameters,
        well1.generate_hifi,
        well1.ccs_analysis_output
      ])

      expect(well_data_2).to eq([
        well2.plate.run.system_name,
        well2.plate.run.name,
        'true',
        well2.position,
        well2.find_pool_barcode,
        well2.movie_time.to_s,
        well2.insert_size.to_s,
        well2.template_prep_kit_box_barcode,
        well2.binding_kit_box_barcode,
        well2.plate.run.sequencing_kit_box_barcode,
        well2.on_plate_loading_concentration.to_s,
        well2.plate.run.dna_control_complex_box_barcode,
        well2.plate.run.comments,
        well2.all_libraries_tagged.to_s,
        '',
        well2.barcode_set,
        well2.same_barcodes_on_both_ends_of_sequence.to_s,
        '',
        well2.automation_parameters,
        well2.generate_hifi,
        well2.ccs_analysis_output
      ])
    end

    it 'must have the correct sample rows' do
      csv_string = csv.generate_sample_sheet
      array_of_rows = CSV.parse(csv_string)

      sample_data_1 = array_of_rows[2]
      sample_data_2 = array_of_rows[8]

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
        ''
      ])
    end
  end

  context '#generate_sample_sheet no tags' do
    let(:well1)   { create(:pacbio_well_with_pools, pre_extension_time: 2, generate_hifi: 'Do Not Generate', ccs_analysis_output: 'Yes') }
    let(:well2)   { create(:pacbio_well_with_pools, generate_hifi: 'On Instrument', ccs_analysis_output: 'No') }
    let(:plate)   { create(:pacbio_plate, wells: [well1, well2]) }
    let(:run)     { create(:pacbio_run, plate: plate) }
    let(:csv)     { ::CsvGenerator.new(run: run, configuration: Pipelines.pacbio.sample_sheet) }

    before(:each) do
      well1.pools.first.libraries = create_list(:pacbio_library, 2, :untagged)
      well2.pools.first.libraries = create_list(:pacbio_library, 2, :untagged)
    end

    it 'check validity' do
      well = create(:pacbio_well)
      well.pools << create_list(:pacbio_pool, 5)
      expect(well).to be_valid
    end

    it 'must return a csv string' do
      csv_string = csv.generate_sample_sheet
      expect(csv_string.class).to eq String
    end

    it 'must have the correct headers' do
      csv_string = csv.generate_sample_sheet
      headers = CSV.parse(csv_string)[0]

      expected_headers = Pipelines.pacbio.sample_sheet.columns.map(&:first)
      expect(headers).to eq(expected_headers)
    end

    it 'must have the correct well header rows' do
      csv_string = csv.generate_sample_sheet
      array_of_rows = CSV.parse(csv_string)

      well_data_1 = array_of_rows[1]
      well_data_2 = array_of_rows[2]

      expect(well_data_1).to eq([
        well1.plate.run.system_name,
        well1.plate.run.name,
        'true',
        well1.position,
        well1.find_pool_barcode,
        well1.movie_time.to_s,
        well1.insert_size.to_s,
        well1.template_prep_kit_box_barcode,
        well1.binding_kit_box_barcode,
        well1.plate.run.sequencing_kit_box_barcode,
        well1.on_plate_loading_concentration.to_s,
        well1.plate.run.dna_control_complex_box_barcode,
        well1.plate.run.comments,
        well1.all_libraries_tagged.to_s,
        '',
        well1.barcode_set,
        well1.same_barcodes_on_both_ends_of_sequence.to_s,
        well1.find_sample_name,
        well1.automation_parameters,
        well1.generate_hifi,
        well1.ccs_analysis_output
      ])

      expect(well_data_2).to eq([
        well2.plate.run.system_name,
        well2.plate.run.name,
        'true',
        well2.position,
        well2.find_pool_barcode,
        well2.movie_time.to_s,
        well2.insert_size.to_s,
        well2.template_prep_kit_box_barcode,
        well2.binding_kit_box_barcode,
        well2.plate.run.sequencing_kit_box_barcode,
        well2.on_plate_loading_concentration.to_s,
        well2.plate.run.dna_control_complex_box_barcode,
        well2.plate.run.comments,
        well2.all_libraries_tagged.to_s,
        '',
        well2.barcode_set,
        well2.same_barcodes_on_both_ends_of_sequence.to_s,
        well2.find_sample_name,
        well2.automation_parameters,
        well2.generate_hifi,
        well2.ccs_analysis_output
      ])
    end

    it 'must not have sample rows' do
      csv_string = csv.generate_sample_sheet
      array_of_rows = CSV.parse(csv_string)

      expect(array_of_rows.size).to eq 3
    end
  end

end
