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

  context 'sequencing mode' do
    it 'must be present' do
      expect(build(:pacbio_run, sequencing_mode: nil)).to_not be_valid
    end

    it 'must include the correct options' do
      expect(Pacbio::Run.sequencing_modes.keys).to eq(['CLR', 'CCS'])
    end
  end
  
end