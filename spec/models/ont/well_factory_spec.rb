require 'rails_helper'

RSpec.describe Ont::WellFactory, type: :model, ont: true do
  let(:plate) { create(:plate) }

  def mock_valid_request_factories
    allow_any_instance_of(Ont::RequestFactory).to receive(:valid?).and_return(true)
    allow_any_instance_of(Ont::RequestFactory).to receive(:save).and_return(true)
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
      expect(factory.errors.full_messages.length).to eq(1)
    end

    it 'produces error messages if given no well attributes' do
      attributes = { plate: plate }
      factory = Ont::WellFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
    end

    it 'produces error messages if generated well is not valid' do
      # well should have a position
      attributes = { plate: plate, well_attributes: {} }
      factory = Ont::WellFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
    end

    it 'produces error messages if any of the request factories are not valid' do
      mock_invalid_request_factories
      allow_any_instance_of(::TagService).to receive(:complete?).and_return(true)
      attributes = { plate: plate, well_attributes: { position: 'A1', samples: [ { name: 'sample 1' } ] } }
      factory = Ont::WellFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
      expect(factory.errors.full_messages).to contain_exactly('Request factories {:message=>"This is a test error"}')
    end

    it 'produces error messages with unsupported number of samples' do
      mock_valid_request_factories
      attributes = { plate: plate, well_attributes: { position: 'A1', samples: [ { name: 'sample 1' }, { name: 'sample 2' } ] } }
      factory = Ont::WellFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
      expect(factory.errors.full_messages).to contain_exactly("Exception raised: '2' is not a supported number of samples")
    end
  end

  context '#save' do
    context 'valid build' do
      let(:well_with_no_sample) { { plate: plate, well_attributes: { position: 'A1' } } }
      let(:well_with_one_sample) { { plate: plate, well_attributes: { position: 'A1', samples: [ { name: 'sample 1' } ] } } }

      before do
        mock_valid_request_factories
      end

      it 'is valid' do
        factory = Ont::WellFactory.new(well_with_no_sample)
        expect(factory).to be_valid
      end

      it 'creates a well' do
        factory = Ont::WellFactory.new(well_with_no_sample)
        expect(factory.save).to be_truthy
        expect(::Well.all.count).to eq(1)
        expect(::Well.all.first.plate).to eq(::Plate.first)
        expect(::Well.first.position).to eq('A1')
      end

      it 'does not create or save any request factories if given no samples' do
        expect(Ont::RequestFactory).to_not receive(:new)
        expect_any_instance_of(Ont::RequestFactory).to_not receive(:save)
        factory = Ont::WellFactory.new(well_with_no_sample)
        expect(factory.save).to be_truthy
      end

      it 'creates and saves a single request factory if given one sample' do
        expect(Ont::RequestFactory).to receive(:new).exactly(1).and_call_original
        expect_any_instance_of(Ont::RequestFactory).to receive(:save)
        factory = Ont::WellFactory.new(well_with_one_sample)
        expect(factory.save).to be_truthy
      end

      it 'validates the well only once by default' do
        validation_count = 0
        allow_any_instance_of(Well).to receive(:valid?) { |_| validation_count += 1 }
        factory = Ont::WellFactory.new(well_with_one_sample)
        factory.save
        expect(validation_count).to eq(1)
      end

      it 'validates the request factories only once each by default' do
        validation_count = 0
        allow_any_instance_of(Ont::RequestFactory).to receive(:valid?) { |_| validation_count += 1 }
        factory = Ont::WellFactory.new(well_with_one_sample)
        factory.save
        expect(validation_count).to eq(1)
      end

      it 'validates no children when (validate: false) is passed' do
        validation_count = 0
        allow_any_instance_of(Well).to receive(:valid?) { |_| validation_count += 1 }
        allow_any_instance_of(Ont::RequestFactory).to receive(:valid?) { |_| validation_count += 1 }
        factory = Ont::WellFactory.new(well_with_one_sample)
        factory.save(validate: false)
        expect(validation_count).to eq(0)
      end
    end

    context 'invalid build' do
      let(:factory) { Ont::WellFactory.new({}) }

      before do
        factory.save
      end

      it 'is invalid' do
        expect(factory).to_not be_valid
      end

      it 'returns false on save' do
        expect(factory.save).to be_falsey
      end

      it 'does not create a well' do
        expect(::Well.all.count).to eq(0)
      end

      it 'does not save any request factories' do
        expect_any_instance_of(Ont::RequestFactory).to_not receive(:save)
      end
    end
  end
end
