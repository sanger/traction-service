require 'rails_helper'

RSpec.describe Ont::RequestFactory, type: :model, ont: true do
  let(:well) { create(:well) }
  let(:tag) { create(:tag) }
  let(:tag_service) { ::TagService.new(tag.tag_set) }

  context '#initialise' do
    

    it 'produces error messages if given no well' do
      attributes = { request_attributes: { external_id: '1' } }
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
    end

    it 'produces error messages if given no request attributes' do
      attributes = { well: well }
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
    end

    it 'produces error messages if the generated sample is not valid' do
      # request attributes should include a name
      attributes = {
        well: well,
        request_attributes: {
          external_id: '1'
        }
      }
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
    end

    it 'produces error messages if the generated ont request is not valid' do
      allow_any_instance_of(Pipelines::ConstantsAccessor).to receive(:external_study_id).and_return(nil)
      attributes = {
        well: well,
        request_attributes: {
          name: 'sample 1',
          external_id: '1'
        }
      }
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages.length).to eq(1)
    end

    context 'with tag service' do
      it 'produces error messages if given attributes contain no tag group id' do
        attributes = {
          well: well,
          tag_service: tag_service,
          request_attributes: {
            name: 'sample 1',
            external_id: '1'
          }
        }
        factory = Ont::RequestFactory.new(attributes)
        expect(factory).to_not be_valid
        expect(factory.errors.full_messages.length).to eq(1)
      end

      it 'produces error messages if no matching tag exists' do
        allow_any_instance_of(::TagService).to receive(:find_and_register_tag).and_return(nil)
        attributes = {
          well: well,
          tag_service: tag_service,
          request_attributes: {
            name: 'sample 1',
            external_id: '1',
            tag_group_id: 'not a valid group id'
          }
        }
        factory = Ont::RequestFactory.new(attributes)
        expect(factory).to_not be_valid
        expect(factory.errors.full_messages.length).to eq(1)
      end
    end
  end

  context '#save' do
    context 'valid build' do
      let(:attributes) { { well: well, request_attributes: { name: 'sample 1', external_id: '1', tag_group_id: tag.group_id } } }

      before do
        allow_any_instance_of(Pipelines::ConstantsAccessor).to receive(:external_study_id).and_return('test external id')
        allow_any_instance_of(Pipelines::ConstantsAccessor).to receive(:species).and_return('test sample species')
      end

      it 'is valid with given attributes' do
        factory = Ont::RequestFactory.new(attributes)
        expect(factory).to be_valid
      end

      it 'creates ont request' do
        factory = Ont::RequestFactory.new(attributes)
        expect(factory.save).to be_truthy
        expect(Ont::Request.all.count).to eq(1)
        expect(Ont::Request.first.external_study_id).to eq('test external id')
        expect(Ont::Request.first.container).to eq(::Well.where(position: 'A1').first)
      end

      context 'without tag service' do
        it 'creates an untagged ont request' do
          factory = Ont::RequestFactory.new(attributes)
          expect(factory.save).to be_truthy
          expect(Ont::Request.first.tags.count).to eq(0)
        end

        it 'does not create a tag taggable' do
          factory = Ont::RequestFactory.new(attributes)
          expect(factory.save).to be_truthy
          expect(::TagTaggable.count).to eq(0)
        end
      end

      context 'with tag service' do
        let(:attributes_with_tag) { attributes.merge(tag_service: tag_service) }

        before do
          allow_any_instance_of(::TagService).to receive(:find_and_register_tag).and_return(tag)
        end

        it 'creates a tagged ont request' do
          factory = Ont::RequestFactory.new(attributes_with_tag)
          expect(factory.save).to be_truthy
          expect(Ont::Request.first.tags.count).to eq(1)
          expect(Ont::Request.first.tags).to contain_exactly(tag)
        end

        it 'creates a tag taggable' do
          factory = Ont::RequestFactory.new(attributes_with_tag)
          expect(factory.save).to be_truthy
          expect(::TagTaggable.count).to eq(1)
          expect(::TagTaggable.first.tag).to eq(tag)
          expect(::TagTaggable.first.taggable).to eq(Ont::Request.first)
        end
      end

      it 'creates a container material' do
        factory = Ont::RequestFactory.new(attributes)
        expect(factory.save).to be_truthy
        expect(::ContainerMaterial.all.count).to eq(1)
        expect(::ContainerMaterial.first.container).to eq(::Well.where(position: 'A1').first)
        expect(::ContainerMaterial.first.material).to eq(Ont::Request.first)
      end

      it 'creates a sample for a request if that sample does not exist' do
        factory = Ont::RequestFactory.new(attributes)
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
        factory = Ont::RequestFactory.new(attributes)
        expect(factory.save).to be_truthy
        expect(::Sample.all.count).to eq(1)
        expect(::Sample.first.requests.count).to eq(1)
        expect(::Sample.first.requests.first.requestable).to eq(Ont::Request.first)
      end
    end

    context 'invalid build' do
      let(:factory) { Ont::RequestFactory.new({}) }

      before do
        factory.save
      end

      it 'is invalid' do
        expect(factory).to_not be_valid
      end

      it 'returns false on save' do
        expect(factory.save).to be_falsey
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

      it 'does not create a tag taggable' do
        expect(TagTaggable.all.count).to eq(0)
      end
    end
  end
end
