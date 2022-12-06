# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContainerMaterial do
  it 'is not valid without a container' do
    expect(build(:container_material, container: nil)).not_to be_valid
  end

  it 'is not valid without a material' do
    expect(build(:container_material, material: nil)).not_to be_valid
  end
end
