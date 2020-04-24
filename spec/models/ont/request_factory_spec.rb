require 'rails_helper'

RSpec.describe Ont::RequestFactory, type: :model, ont: true do
  context '#initialise' do
    it 'produces error messages if the plate is not valid' do
      # mock a plate to not be valid and as such has an error
      allow_any_instance_of(::Plate).to receive(:valid?).and_return(false)
      allow_any_instance_of(::Plate).to receive(:errors).and_return({ plate: 'has an error' })
      attributes = {
        wells: [
          {
            position: 'A1',
            sample: {
              name: 'sample 1',
              external_id: '1'
            }
          }
        ]
      }
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
    end

    it 'produces error messages if given no wells' do
      attributes = { barcode: 'abc123' }
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
    end

    it 'produces error messages if given wells are empty' do
      attributes = { barcode: 'abc123', wells: [] }
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
    end

    it 'produces error messages if any of the wells are not valid' do
      # well is invalid (should have a position)
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
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
    end

    it 'produces error messages if any of the requests/samples are not valid' do
      # the request is invalid as it's sample is invalid (should have a name)
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
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
    end

    it 'produces error messages if any of the joins are not valid' do
      # mock the join to not be valid and as such has an error
      allow_any_instance_of(::ContainerMaterial).to receive(:valid?).and_return(false)
      allow_any_instance_of(::ContainerMaterial).to receive(:errors).and_return({ container_material: 'has an error' })
      attributes = {
        barcode: 'abc123',
        wells: [
          {
            position: 'A1',
            sample: {
              name: 'sample 1',
              external_id: '1'
            }
          }
        ]
      }
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
    end
  end

  context '#save' do
    let(:attributes) { { barcode: 'abc123', wells: [  { position: 'A1', sample: { name: 'sample 1', external_id: '1' } }, { position: "A2" } ] } }
    
    it 'creates a plate' do
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(::Plate.all.count).to eq(1)
      expect(::Plate.first.barcode).to eq('abc123')
      expect(factory.plate).to eq(::Plate.first)
    end

    it 'creates a well for each given well' do
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(::Well.all.count).to eq(2)
      expect(::Well.all.collect(&:plate).uniq.count).to eq(1)
      expect(::Well.all.collect(&:plate).uniq[0]).to eq(::Plate.first)
      expect(::Well.first.position).to eq('A1')
      expect(::Well.second.position).to eq('A2')
    end

    it 'creates an ont request in a well for each given well with a sample' do
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(Ont::Request.all.count).to eq(1)
      expect(Ont::Request.first.external_study_id).to eq('example id')
      expect(Ont::Request.first.container).to eq(::Well.where(position: 'A1').first)
    end

    it 'creates a request for each ont request' do
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(::Request.all.count).to eq(1)
      expect(::Request.first.requestable).to eq(Ont::Request.first)
    end

    it 'creates a container material for each ont request' do
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(::ContainerMaterial.all.count).to eq(1)
      expect(::ContainerMaterial.first.container).to eq(::Well.where(position: 'A1').first)
      expect(::ContainerMaterial.first.material).to eq(Ont::Request.first)
    end

    it 'creates a sample for a request if that sample does not exist' do
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to be_valid
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
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(::Sample.all.count).to eq(1)
      expect(::Sample.first.requests.count).to eq(1)
      expect(::Sample.first.requests.first.requestable).to eq(Ont::Request.first)
    end

    it 'does not create a plate if the builds are not valid' do
      factory = Ont::RequestFactory.new({})
      expect(factory).to_not be_valid
      expect(factory.save).to be_falsey
      expect(::Plate.all.count).to eq(0)
    end

    it 'does not create any wells if the builds are not valid' do
      factory = Ont::RequestFactory.new({})
      expect(factory).to_not be_valid
      expect(factory.save).to be_falsey
      expect(::Well.all.count).to eq(0)
    end

    it 'does not create any ont requests if the builds are not valid' do
      factory = Ont::RequestFactory.new({})
      expect(factory).to_not be_valid
      expect(factory.save).to be_falsey
      expect(Ont::Request.all.count).to eq(0)
    end

    it 'does not create any requests if the builds are not valid' do
      factory = Ont::RequestFactory.new({})
      expect(factory).to_not be_valid
      expect(factory.save).to be_falsey
      expect(::Request.all.count).to eq(0)
    end

    it 'does not create any samples if the build are not valid' do
      factory = Ont::RequestFactory.new({})
      expect(factory).to_not be_valid
      expect(factory.save).to be_falsey
      expect(::Sample.all.count).to eq(0)
    end

    it 'does not create any joins if the builds are not valid' do
      factory = Ont::RequestFactory.new({})
      expect(factory).to_not be_valid
      expect(factory.save).to be_falsey
      expect(::ContainerMaterial.all.count).to eq(0)
    end
  end
end
