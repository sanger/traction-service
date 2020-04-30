require 'rails_helper'

RSpec.describe Ont::PlateFactory, type: :model, ont: true do
  def mock_valid_well_factories
    allow_any_instance_of(Ont::WellFactory).to receive(:valid?).and_return(true)
    allow_any_instance_of(Ont::WellFactory).to receive(:save).and_return(true)
  end

  def mock_invalid_well_factories
    errors = ActiveModel::Errors.new(Ont::WellFactory.new)
    errors.add('well factories', message: 'This is a test error')

    allow_any_instance_of(Ont::WellFactory).to receive(:valid?).and_return(false)
    allow_any_instance_of(Ont::WellFactory).to receive(:errors).and_return(errors)
  end

  context '#initialise' do
    it 'produces error messages if given no wells' do
      attributes = { barcode: 'abc123' }
      factory = Ont::PlateFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
    end

    it 'produces error messages if given wells are empty' do
      attributes = { barcode: 'abc123', wells: [] }
      factory = Ont::PlateFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
    end

    it 'produces error messages if any of the well factories are not valid' do
      mock_invalid_well_factories
      attributes = { barcode: 'abc123', wells: [ { position: 'A1' } ] }
      factory = Ont::PlateFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
      expect(factory.errors.full_messages).to contain_exactly('Well factories {:message=>"This is a test error"}')
    end
  end

  context '#save' do
    let(:attributes) { { barcode: 'abc123', wells: [ { position: 'A1' }, { position: "A2" } ] } }
    context 'valid build' do  
      let(:factory) { Ont::PlateFactory.new(attributes) }

      before do
        mock_valid_well_factories
      end

      it 'is valid with given attributes' do
        expect(factory).to be_valid
      end
      
      it 'creates a plate' do
        expect(factory.save).to be_truthy
        expect(::Plate.all.count).to eq(1)
        expect(::Plate.first.barcode).to eq('abc123')
        expect(factory.plate).to eq(::Plate.first)
      end

      it 'creates a well factory for each given well' do
        expect(Ont::WellFactory).to receive(:new).exactly(2).and_call_original
        expect(factory.save).to be_truthy
      end
    end

    context 'invalid build' do
      factory = nil

      before do
        mock_invalid_well_factories
        factory = Ont::PlateFactory.new(attributes)
        factory.save
      end

      it 'is invalid' do
        expect(factory).to_not be_valid
      end

      it 'returns false on save' do
        expect(factory.save).to be_falsey
      end

      it 'does not create a plate' do
        expect(::Plate.all.count).to eq(0)
      end
  
      it 'does not save any well factories' do
        expect_any_instance_of(Ont::WellFactory).to_not receive(:save)
      end
    end
  end
end
