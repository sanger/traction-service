# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContainerMaterial, type: :model do
  it 'is not valid without a container' do
    expect(build(:container_material, container: nil)).to_not be_valid
  end

  it 'is not valid without a material' do
    expect(build(:container_material, material: nil)).to_not be_valid
  end

  context 'resolve' do
    it 'returns expected includes_args' do
      expect(ContainerMaterial.includes_args).to contain_exactly(:container, :material)
    end

    it 'removes container from includes_args' do
      expect(ContainerMaterial.includes_args(:container)).to_not include(:container)
    end

    it 'removes run from includes_args' do
      expect(ContainerMaterial.includes_args(:material)).to_not include(:material)
    end
  end
end
