require 'rails_helper'

RSpec.describe Well, type: :model do
  it_behaves_like 'container'
  
  it 'must have plate' do
    expect(build(:well, plate: nil)).to_not be_valid
  end

  it 'must have a position' do
    expect(build(:well, position: nil)).to_not be_valid
  end

  it 'gets row from position' do
    well = create(:well, position: 'B6')
    expect(well.row).to eq('B')
  end

  it 'gets column from position' do
    well = create(:well, position: 'B6')
    expect(well.column).to eq(6)
  end

  it 'gets two digit column from position' do
    well = create(:well, position: 'B12')
    expect(well.column).to eq(12)
  end
end
