require 'rails_helper'

RSpec.describe Pacbio::Plate, type: :model, pacbio: true do

  context 'uuidable' do
    let(:uuidable_model) { :pacbio_plate }
    it_behaves_like 'uuidable'
  end

  it 'must have a run' do
    expect(build(:pacbio_plate, run: nil)).to_not be_valid
  end

  context '#all_wells_have_libraries?' do

    it 'all with libraries' do
      plate = create(:pacbio_plate, wells: create_list(:pacbio_well_with_libraries, 2))
      expect(plate.all_wells_have_libraries?).to be_truthy
    end

    it 'some with libraries' do
      plate = create(:pacbio_plate, wells: create_list(:pacbio_well_with_libraries, 2) + create_list(:pacbio_well, 2))
      expect(plate.all_wells_have_libraries?).to be_falsey
    end

    it 'none with libraries' do
      plate =  create(:pacbio_plate, wells: create_list(:pacbio_well, 2))
      expect(plate.all_wells_have_libraries?).to be_falsey
    end

    it 'with no wells at all' do
      plate = create(:pacbio_plate)
      expect(plate.all_wells_have_libraries?).to be_falsey
    end

  end
  
end