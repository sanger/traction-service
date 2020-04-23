require 'rails_helper'

RSpec.describe ContainerMaterialFactory, type: :model do
  context '#initialise' do
    it 'produces error messages if the container material is not valid' do
      factory = ContainerMaterialFactory.new({})
      expect(factory).not_to be_valid
      expect(factory.errors.full_messages).not_to be_empty
    end
  end

  context '#save' do
    it 'creates a container material from the given attributes' do
      well = build(:well)
      request = build(:ont_request)
      attributes = { container: well, material: request }
      factory = ContainerMaterialFactory.new(attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(ContainerMaterial.all.count).to eq(1)
      expect(ContainerMaterial.first.container).to eq(well)
      expect(ContainerMaterial.first.material).to eq(request)
    end

    it 'does not create a container material if the attributes are not valid' do
      factory = ContainerMaterialFactory.new({})
      expect(factory).not_to be_valid
      expect(factory.save).to be_falsey
      expect(ContainerMaterial.all.count).to eq(0)
    end
  end

end
