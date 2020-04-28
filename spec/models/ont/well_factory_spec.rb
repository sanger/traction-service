require 'rails_helper'

RSpec.describe Ont::WellFactory, type: :model, ont: true do
  context '#initialise' do
    let(:plate) { create(:plate) }

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

    it 'produces error messages if the generated sample is not valid' do
      # sample should have a name
      attributes = {
        plate: plate,
        well_attributes: {
          position: 'A1',
          sample: {
            external_id: '1'
          }
        }
      }
      factory = Ont::WellFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
    end

    it 'produces error messages if the generated ont request is not valid' do
      allow_any_instance_of(Pipelines::ConstantsAccessor).to receive(:external_study_id).and_return(nil)
      attributes = {
        plate: plate,
        well_attributes: {
          position: 'A1',
          sample: {
            name: 'sample 1',
            external_id: '1'
          }
        }
      }
      factory = Ont::WellFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
    end
  end

  context '#save' do
    context 'valid build' do
      let(:plate) { create(:plate) }
      let(:well_with_sample) { { plate: plate, well_attributes: { position: 'A1', sample: { name: 'sample 1', external_id: '1' } } } }

      before do
        allow_any_instance_of(Pipelines::ConstantsAccessor).to receive(:external_study_id).and_return('test external id')
        allow_any_instance_of(Pipelines::ConstantsAccessor).to receive(:species).and_return('test sample species')
      end

      it 'is valid with given attributes' do
        factory = Ont::WellFactory.new(well_with_sample)
        expect(factory).to be_valid
      end

      it 'creates a well' do
        factory = Ont::WellFactory.new(well_with_sample)
        expect(factory.save).to be_truthy
        expect(::Well.all.count).to eq(1)
        expect(::Well.all.first.plate).to eq(::Plate.first)
        expect(::Well.first.position).to eq('A1')
      end

      context 'with sample' do
        let(:factory) { Ont::WellFactory.new(well_with_sample) }

        it 'creates an ont request' do
          expect(factory.save).to be_truthy
          expect(Ont::Request.all.count).to eq(1)
          expect(Ont::Request.first.external_study_id).to eq('test external id')
          expect(Ont::Request.first.container).to eq(::Well.where(position: 'A1').first)
        end

        it 'creates a request' do
          expect(factory.save).to be_truthy
          expect(::Request.all.count).to eq(1)
          expect(::Request.first.requestable).to eq(Ont::Request.first)
        end

        it 'creates a container material' do
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
          expect(::Sample.first.species).to eq('test sample species')
          expect(::Sample.first.requests.count).to eq(1)
          expect(::Sample.first.requests.first.requestable).to eq(Ont::Request.first)
        end

        it 'does not create a sample for a request if that sample already exists' do
          create(:sample, name: 'sample 1', external_id: '1', species: 'test sample species')
          expect(factory.save).to be_truthy
          expect(::Sample.all.count).to eq(1)
          expect(::Sample.first.requests.count).to eq(1)
          expect(::Sample.first.requests.first.requestable).to eq(Ont::Request.first)
        end
      end

      context 'without sample' do
        let(:well_without_sample) { { plate: plate, well_attributes: { position: 'A2' } } }
        let(:factory) { Ont::WellFactory.new(well_without_sample) }

        it 'does not create an ont request' do
          expect(factory.save).to be_truthy
          expect(Ont::Request.all.count).to eq(0)
        end

        it 'does not create a request' do
          expect(factory.save).to be_truthy
          expect(::Request.all.count).to eq(0)
        end

        it 'does not create a container material' do
          expect(factory.save).to be_truthy
          expect(::ContainerMaterial.all.count).to eq(0)
        end

        it 'does not create a sample' do
          expect(factory.save).to be_truthy
          expect(::Sample.all.count).to eq(0)
        end
      end
    end

    context 'invalid build' do
      let(:factory) { Ont::WellFactory.new({}) }

      it 'is invalid' do
        expect(factory).to_not be_valid
      end

      it 'returns false on save' do
        expect(factory.save).to be_falsey
      end

      it 'does not create a well' do
        expect(::Well.all.count).to eq(0)
      end

      it 'does not create an ont request' do
        expect(Ont::Request.all.count).to eq(0)
      end

      it 'does not create a request' do
        expect(::Request.all.count).to eq(0)
      end

      it 'does not create a sample' do
        expect(::Sample.all.count).to eq(0)
      end

      it 'does not create a join' do
        expect(::ContainerMaterial.all.count).to eq(0)
      end
    end
  end
end
