require 'rails_helper'

RSpec.describe Pacbio::Plate, type: :model, pacbio: true do

  it 'must have a run' do
    expect(build(:pacbio_plate, run: nil)).to_not be_valid
  end

  it 'must have a barcode' do
    expect(build(:pacbio_plate, barcode: nil)).to_not be_valid
  end

  it 'will have a uuid' do
    expect(create(:pacbio_plate).uuid).to be_present
  end
  
end