require 'rails_helper'

RSpec.describe ContainerMaterial, type: :model do
  it 'is not valid without a container' do
    expect(build(:container_material, container: nil)).to_not be_valid
  end

  it 'is not valid without a material' do
    expect(build(:container_material, material: nil)).to_not be_valid
  end
end
