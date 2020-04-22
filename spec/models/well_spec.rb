require 'rails_helper'

RSpec.describe Well, type: :model do

  it 'must have plate' do
    expect(build(:well, plate: nil)).to_not be_valid
  end

  it 'must have a position' do
    expect(build(:well, position: nil)).to_not be_valid
  end

  it 'can have a material' do
    well = create(:well)
    container_material = create(:container_material, container: well)
    expect(well.material).to eq(container_material.material)
  end

end
