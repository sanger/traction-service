require 'rails_helper'

RSpec.describe Ont::WellFactory, type: :model, ont: true do
  let(:plate) { create(:plate) }

  def mock_valid_request_factories
    allow_any_instance_of(Ont::RequestFactory).to receive(:valid?).and_return(true)
    allow_any_instance_of(Ont::RequestFactory).to receive(:bulk_insert_serialise).and_return('request data')
  end

  def mock_invalid_request_factories
    errors = ActiveModel::Errors.new(Ont::RequestFactory.new)
    errors.add('request factories', message: 'This is a test error')

    allow_any_instance_of(Ont::RequestFactory).to receive(:valid?).and_return(false)
    allow_any_instance_of(Ont::RequestFactory).to receive(:errors).and_return(errors)
  end

  context '#initialise' do
    it 'produces error messages if given no plate' do
      attributes = { well_attributes: { position: 'A1' } }
      factory = Ont::WellFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

    it 'produces error messages if given no well attributes' do
      attributes = { plate: plate }
      factory = Ont::WellFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

    it 'produces error messages if generated well is not valid' do
      # well should have a position
      attributes = { plate: plate, well_attributes: {} }
      factory = Ont::WellFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

    it 'produces error messages if the request factory is not valid' do
      mock_invalid_request_factories
      attributes = { plate: plate, well_attributes: { position: 'A1', sample: { name: 'sample 1' } } }
      factory = Ont::WellFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
      expect(factory.errors.full_messages).to contain_exactly('Request factories {:message=>"This is a test error"}')
    end
  end

  context '#bulk_insert_serialise' do
    let(:bulk_insert_serialiser) { double() }

    context 'valid build' do
      let(:well_with_no_sample) { { plate: plate, well_attributes: { position: 'A1' } } }
      let(:well_with_one_sample) { { plate: plate, well_attributes: { position: 'A1', sample: { name: 'sample 1' } } } }
      let(:response) { 'well data' }

      before do
        mock_valid_request_factories
        allow(bulk_insert_serialiser).to receive(:well_data).with(an_instance_of(Well), an_instance_of(Array)).and_return(response)
      end

      it 'is valid' do
        factory = Ont::WellFactory.new(well_with_no_sample)
        expect(factory).to be_valid
      end

      it 'has expected response with no samples' do
        factory = Ont::WellFactory.new(well_with_no_sample)
        expect(factory.bulk_insert_serialise(bulk_insert_serialiser)).to eq(response)
      end

      it 'has expected response with one sample' do
        factory = Ont::WellFactory.new(well_with_one_sample)
        expect(factory.bulk_insert_serialise(bulk_insert_serialiser)).to eq(response)
      end

      it 'does not create or call any request factories if given no samples' do
        expect(Ont::RequestFactory).to_not receive(:new)
        expect_any_instance_of(Ont::RequestFactory).to_not receive(:bulk_insert_serialise)
        factory = Ont::WellFactory.new(well_with_no_sample)
        expect(factory.bulk_insert_serialise(bulk_insert_serialiser)).to be_truthy
      end

      it 'creates and calls a single request factory if given one sample' do
        expect(Ont::RequestFactory).to receive(:new).exactly(1).and_call_original
        expect_any_instance_of(Ont::RequestFactory).to receive(:bulk_insert_serialise)
        factory = Ont::WellFactory.new(well_with_one_sample)
        expect(factory.bulk_insert_serialise(bulk_insert_serialiser)).to be_truthy
      end

      it 'validates the well only once by default' do
        validation_count = 0
        allow_any_instance_of(Well).to receive(:valid?) { |_| validation_count += 1 }
        factory = Ont::WellFactory.new(well_with_one_sample)
        factory.bulk_insert_serialise(bulk_insert_serialiser)
        expect(validation_count).to eq(1)
      end

      it 'validates the request factories only once each by default' do
        validation_count = 0
        allow_any_instance_of(Ont::RequestFactory).to receive(:valid?) { |_| validation_count += 1 }
        factory = Ont::WellFactory.new(well_with_one_sample)
        factory.bulk_insert_serialise(bulk_insert_serialiser)
        expect(validation_count).to eq(1)
      end

      it 'validates no children when (validate: false) is passed' do
        validation_count = 0
        allow_any_instance_of(Well).to receive(:valid?) { |_| validation_count += 1 }
        allow_any_instance_of(Ont::RequestFactory).to receive(:valid?) { |_| validation_count += 1 }
        factory = Ont::WellFactory.new(well_with_one_sample)
        factory.bulk_insert_serialise(bulk_insert_serialiser, validate: false)
        expect(validation_count).to eq(0)
      end
    end

    context 'invalid build' do
      let(:factory) { Ont::WellFactory.new({}) }

      it 'is invalid' do
        expect(factory).to_not be_valid
      end

      it 'returns false' do
        response = factory.bulk_insert_serialise(bulk_insert_serialiser)
        expect(response).to be_falsey
      end
    end
  end
end
