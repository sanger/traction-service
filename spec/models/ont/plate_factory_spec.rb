require 'rails_helper'

RSpec.describe Ont::PlateFactory, type: :model, ont: true do
  def mock_valid_well_factories
    allow_any_instance_of(Ont::WellFactory).to receive(:valid?).and_return(true)
    allow_any_instance_of(Ont::WellFactory).to receive(:bulk_insert_serialise).and_return('well data')
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

  context '#bulk_insert_serialise' do
    let(:bulk_insert_serialiser) { double() }
    let(:attributes) { { barcode: 'abc123', wells: [ { position: 'A1' }, { position: "A2" } ] } }

    context 'valid build' do
      let(:factory) { Ont::PlateFactory.new(attributes) }
      let(:response) { 'plate data' }

      before do
        mock_valid_well_factories
        allow(bulk_insert_serialiser).to receive(:plate_data).with(an_instance_of(Plate), an_instance_of(Array)).and_return(response)
      end

      it 'is valid with given attributes' do
        expect(factory).to be_valid
      end

      it 'has expected response' do
        expect(factory.bulk_insert_serialise(bulk_insert_serialiser)).to eq(response)
      end

      it 'creates a well factory for each given well' do
        expect(Ont::WellFactory).to receive(:new).exactly(2).and_call_original
        factory.bulk_insert_serialise(bulk_insert_serialiser)
      end

      it 'validates the plate only once by default' do
        validation_count = 0
        allow_any_instance_of(Plate).to receive(:valid?) { |_| validation_count += 1 }
        factory.bulk_insert_serialise(bulk_insert_serialiser)
        expect(validation_count).to eq(1)
      end

      it 'validates the well factories only once each by default' do
        validation_count = 0
        allow_any_instance_of(Ont::WellFactory).to receive(:valid?) { |_| validation_count += 1 }
        factory.bulk_insert_serialise(bulk_insert_serialiser)
        expect(validation_count).to eq(2)
      end

      it 'validates no children when (validate: false) is passed' do
        validation_count = 0
        allow_any_instance_of(Plate).to receive(:valid?) { |_| validation_count += 1 }
        allow_any_instance_of(Ont::WellFactory).to receive(:valid?) { |_| validation_count += 1 }
        factory.bulk_insert_serialise(bulk_insert_serialiser, validate: false)
        expect(validation_count).to eq(0)
      end
    end

    context 'invalid build' do
      before do
        mock_invalid_well_factories
      end

      it 'is invalid' do
        factory = Ont::PlateFactory.new(attributes)
        expect(factory).to_not be_valid
      end

      it 'returns false on save' do
        factory = Ont::PlateFactory.new(attributes)
        expect(factory.bulk_insert_serialise(bulk_insert_serialiser)).to be_falsey
      end
    end
  end
end
