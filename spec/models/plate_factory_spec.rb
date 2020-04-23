require 'rails_helper'

RSpec.describe PlateFactory, type: :model do
  context '#initialise' do
    it 'produces error messages if the plate has no barcode' do
      factory = PlateFactory.new({})
      expect(factory).not_to be_valid
      expect(factory.errors.full_messages.length).to eq(1)
      expect(factory.errors.full_messages[0]).not_to be_blank
    end
  end

  context '#save' do
    it 'creates a plate from the given attributes' do
      attributes = { barcode: 'abc123' }
      factory = PlateFactory.new(attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(Plate.all.count).to eq(1)
      expect(Plate.first.barcode).to eq('abc123')
    end

    it 'does not create a plate if the attributes are not valid' do
      factory = PlateFactory.new({})
      expect(factory).not_to be_valid
      expect(factory.save).to be_falsey
      expect(Plate.all.count).to eq(0)
    end
  end

end
