require 'rails_helper'

RSpec.describe Ont::PlateFactory, type: :model, ont: true do
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

    it 'produces error messages if any of the wells are not valid' do
      # well should have a position
      attributes = {
        barcode: 'abc123',
        wells: [
          {
            sample: {
              name: 'sample 1',
              external_id: '1'
            }
          }
        ]
      }
      factory = Ont::PlateFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
    end

    it 'produces error messages if any of the samples are not valid' do
      # sample should have a name
      attributes = {
        barcode: 'abc123',
        wells: [
          {
            position: 'A1',
            sample: {
              external_id: '1'
            }
          }
        ]
      }
      factory = Ont::PlateFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
    end
  end

  context '#save' do
    context 'valid build' do
      let(:attributes) { { barcode: 'abc123', wells: [  { position: 'A1', sample: { name: 'sample 1', external_id: '1' } }, { position: "A2" } ] } }
      let(:factory) { Ont::PlateFactory.new(attributes) }
  
      it 'is valid with given attributes' do
        expect(factory).to be_valid
      end
      
      it 'creates a plate' do
        expect(factory.save).to be_truthy
        expect(::Plate.all.count).to eq(1)
        expect(::Plate.first.barcode).to eq('abc123')
        expect(factory.plate).to eq(::Plate.first)
      end
  
      it 'creates a well for each given well' do
        expect(factory.save).to be_truthy
        expect(::Well.all.count).to eq(2)
        expect(::Well.all.collect(&:plate).uniq.count).to eq(1)
        expect(::Well.all.collect(&:plate).uniq[0]).to eq(::Plate.first)
        expect(::Well.first.position).to eq('A1')
        expect(::Well.second.position).to eq('A2')
      end
  
      it 'creates an ont request in a well for each given well with a sample' do
        expect(factory.save).to be_truthy
        expect(Ont::Request.all.count).to eq(1)
        expect(Ont::Request.first.external_study_id).to eq('example id')
        expect(Ont::Request.first.container).to eq(::Well.where(position: 'A1').first)
      end
  
      it 'creates a request for each ont request' do
        expect(factory.save).to be_truthy
        expect(::Request.all.count).to eq(1)
        expect(::Request.first.requestable).to eq(Ont::Request.first)
      end
  
      it 'creates a container material for each ont request' do
        expect(factory.save).to be_truthy
        expect(::ContainerMaterial.all.count).to eq(1)
        expect(::ContainerMaterial.first.container).to eq(::Well.where(position: 'A1').first)
        expect(::ContainerMaterial.first.material).to eq(Ont::Request.first)
      end
  
      it 'creates a sample for a request if that sample does not exist' do
        expect(factory.save).to be_truthy
        expect(::Sample.all.count).to eq(1)
        expect(::Sample.first.name).to eq('sample 1')
        expect(::Sample.first.external_id).to eq('1')
        expect(::Sample.first.species).to eq('example species')
        expect(::Sample.first.requests.count).to eq(1)
        expect(::Sample.first.requests.first.requestable).to eq(Ont::Request.first)
      end
  
      it 'does not create a sample for a request if that sample already exists' do
        create(:sample, name: 'sample 1', external_id: '1', species: 'example species')
        expect(factory.save).to be_truthy
        expect(::Sample.all.count).to eq(1)
        expect(::Sample.first.requests.count).to eq(1)
        expect(::Sample.first.requests.first.requestable).to eq(Ont::Request.first)
      end
    end

    context 'invalid build' do
      let(:factory) { Ont::PlateFactory.new({}) }

      it 'is invalid' do
        expect(factory).to_not be_valid
      end

      it 'returns false on save' do
        expect(factory.save).to be_falsey
      end

      it 'does not create a plate' do
        expect(::Plate.all.count).to eq(0)
      end
  
      it 'does not create any wells' do
        expect(::Well.all.count).to eq(0)
      end
  
      it 'does not create any ont requests' do
        expect(Ont::Request.all.count).to eq(0)
      end
  
      it 'does not create any requests' do
        expect(::Request.all.count).to eq(0)
      end
  
      it 'does not create any samples' do
        expect(::Sample.all.count).to eq(0)
      end
  
      it 'does not create any joins' do
        expect(::ContainerMaterial.all.count).to eq(0)
      end
    end
  end
end
