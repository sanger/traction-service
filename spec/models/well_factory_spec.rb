require 'rails_helper'

RSpec.describe WellFactory, type: :model do
  context '#initialise' do
    it 'produces error messages if the well is not valid' do
      factory = WellFactory.new({})
      expect(factory).not_to be_valid
      expect(factory.errors.full_messages).not_to be_empty
    end
  end

  context '#save' do
    it 'creates a well from the given attributes' do
      plate = build(:plate)
      attributes = { position: 'A1', plate: plate }
      factory = WellFactory.new(attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(Well.all.count).to eq(1)
      expect(Well.first.position).to eq('A1')
      expect(Well.first.plate).to eq(plate)
    end

    it 'does not create a well if the attributes are not valid' do
      factory = WellFactory.new({})
      expect(factory).not_to be_valid
      expect(factory.save).to be_falsey
      expect(Well.all.count).to eq(0)
    end
  end

end
