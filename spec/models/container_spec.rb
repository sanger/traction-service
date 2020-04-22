require 'rails_helper'

RSpec.describe Container, type: :model do
  it 'is not valid without a receptacle' do
    expect(build(:container, receptacle: nil)).to_not be_valid
  end

  it 'is not valid without a material' do
    expect(build(:container, material: nil)).to_not be_valid
  end
end
