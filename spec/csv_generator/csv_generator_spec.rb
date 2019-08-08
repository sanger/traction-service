require "rails_helper"

RSpec.describe CSVGenerator, type: :model do
  after(:each) { File.delete('sample_sheet.csv') if File.exists?('sample_sheet.csv') }

  context '#generate_sample_sheet' do
    let(:well1)   { create(:pacbio_well_with_libraries, sequencing_mode: 'CCS') }
    let(:well2)   { create(:pacbio_well_with_libraries, sequencing_mode: 'CLR') }
    let(:plate)   { create(:pacbio_plate, wells: [well1, well2]) }
    let(:run)     { create(:pacbio_run, plate: plate) }
    let(:csv)     { ::CSVGenerator.new(run: run, configuration: Pipelines.pacbio.sample_sheet) }

    it 'check validity' do
      well = create(:pacbio_well)
      well.libraries = create_list(:pacbio_library, 5)
      expect(true).to be_truthy
    end

    it 'must return a csv file' do
      csv_file = csv.generate_sample_sheet
      expect(csv_file.class).to eq CSV
    end

    it 'must have the correct headers' do
      csv_file = csv.generate_sample_sheet
      headers = CSV.read(csv_file.path)[0]

      expected_headers = Pipelines.pacbio.sample_sheet.columns.map(&:first)
      expect(headers).to eq(expected_headers)
    end

    
    it 'must have the correct body' do
      csv_file = csv.generate_sample_sheet
      array_of_rows = CSV.read(csv_file.path)

      well_data_1 = array_of_rows[1]
      well_data_2 = array_of_rows[2]

      expect(well_data_1).to eq([
        well1.plate.run.system_name,
        well1.plate.run.name,
        well1.position,
        well1.sample_names,
        well1.movie_time.to_s,
        well1.insert_size.to_s,
        well1.plate.run.template_prep_kit_box_barcode,
        well1.plate.run.binding_kit_box_barcode,
        well1.plate.run.sequencing_kit_box_barcode,
        well1.sequencing_mode,
        well1.on_plate_loading_concentration.to_s,
        well1.plate.run.dna_control_complex_box_barcode,
        well1.generate_ccs_data.to_s
      ])

      expect(well_data_2).to eq([
        well2.plate.run.system_name,
        well2.plate.run.name,
        well2.position,
        well2.sample_names,
        well2.movie_time.to_s,
        well2.insert_size.to_s,
        well2.plate.run.template_prep_kit_box_barcode,
        well2.plate.run.binding_kit_box_barcode,
        well2.plate.run.sequencing_kit_box_barcode,
        well2.sequencing_mode,
        well2.on_plate_loading_concentration.to_s,
        well2.plate.run.dna_control_complex_box_barcode,
        well2.generate_ccs_data.to_s
      ])
    end
  end

end
