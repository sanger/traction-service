require 'rails_helper'

RSpec.describe Pacbio::Run, type: :model, pacbio: true do

  it 'must have a name' do
    expect(build(:pacbio_run, name: nil)).to_not be_valid
  end

  it 'must have a template prep kit box barcode' do
    expect(build(:pacbio_run, template_prep_kit_box_barcode: nil)).to_not be_valid
  end

  it 'must have a binding kit box barcode' do
    expect(build(:pacbio_run, binding_kit_box_barcode: nil)).to_not be_valid
  end

  it 'must have a sequencing kit box barcode' do
    expect(build(:pacbio_run, sequencing_kit_box_barcode: nil)).to_not be_valid
  end

  it 'must have a DNA control complex kit box barcode' do
    expect(build(:pacbio_run, dna_control_complex_box_barcode: nil)).to_not be_valid
  end

  it 'can have a plate' do
    plate = create(:pacbio_plate)
    run = create(:pacbio_run, plate: plate)
    expect(run.plate).to eq(plate)
  end

  it 'can have comments' do
    wells = create_list(:pacbio_well_with_library, 2)
    plate = create(:pacbio_plate, wells: wells)
    run = create(:pacbio_run, plate: plate)
    expect(run.comments).to eq("#{wells.first.summary};#{wells[1].summary}")
  end

  context '#test_csv' do
    it 'must create a csv file' do
      wells = create_list(:pacbio_well_with_library, 2)
      plate = create(:pacbio_plate, wells: wells)
      run = create(:pacbio_run, plate: plate)

      csv_file = run.test_csv

      array_of_rows = CSV.read(csv_file.path)

      header = array_of_rows[0]
      data1 = array_of_rows[1]
      data2 = array_of_rows[2]

      expect(header).to eq([
        "System name",
        "Run Name",
        "Sample Well",
        "Sample Name",
        "Movie Time per SMRT Cell (hours)",
        "Insert Size (bp)",
        "Template Prep Kit (Box Barcode)",
        "Binding Kit (Box Barcode)",
        "Sequencing Kit (Box Barcode)",
        "Sequencing Mode (CLR/ CCS ) ",
        "On plate loading concentration (mP)",
        "DNA Control Complex (Box Barcode)",
        "Generate CCS Data"
      ])

      well1 = wells[0]
      well2 = wells[1]

      expect(data1).to eq([
        'Sequel I',
        run.name,
        well1.position,
        well1.library.sample.name,
        well1.movie_time.to_s,
        well1.insert_size.to_s,
        run.template_prep_kit_box_barcode,
        run.binding_kit_box_barcode,
        run.sequencing_kit_box_barcode,
        well1.sequencing_mode,
        well1.on_plate_loading_concentration.to_s,
        run.dna_control_complex_box_barcode,
        'ccs data'
      ])

      expect(data2).to eq([
        'Sequel I',
        run.name,
        well2.position,
        well2.library.sample.name,
        well2.movie_time.to_s,
        well2.insert_size.to_s,
        run.template_prep_kit_box_barcode,
        run.binding_kit_box_barcode,
        run.sequencing_kit_box_barcode,
        well2.sequencing_mode,
        well2.on_plate_loading_concentration.to_s,
        run.dna_control_complex_box_barcode,
        'ccs data'
      ])
    end
  end

end
