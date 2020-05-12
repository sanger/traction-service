require 'rails_helper'

RSpec.describe Ont::RequestFactory, type: :model, ont: true do
  let(:well) { create(:well) }
  let(:tag_set) { create(:tag_set_with_tags, name: 'OntWell96Samples') }

  context '#initialise' do
    it 'is not valid if given no well' do
      attributes = { request_attributes: { external_id: '1' } }
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

    it 'is not valid if given no attributes' do
      attributes = { well: well }
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

    it 'is not valid if the generated ont request is not valid' do
      # request attributes should include a name
      attributes = {
        well: well,
        request_attributes: {
          external_id: '1',
          tag_oligoo: tag_set.tags.first.oligo
        }
      }
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

    it 'is not valid if no matching tag exists' do
      attributes = {
        well: well,
        request_attributes: {
          name: 'sample 1',
          external_id: '1',
          tag_oligo: 'NOT_AN_OLIGO'
        }
      }
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

    it 'is not valid if the tag is not in the correct tag set' do
      wrong_tag_set = create(:tag_set_with_tags, name: 'WrongTagSet')
      attributes = {
        well: well,
        request_attributes: {
          name: 'sample 1',
          external_id: '1',
          tag_oligo: wrong_tag_set.tags.first.oligo
        }
      }
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

  end

  context '#save' do
    context 'valid build' do
      let(:attributes) { { well: well, request_attributes: { name: 'sample 1', external_id: '1', tag_oligo: tag_set.tags.first.oligo } } }
      let(:factory) { Ont::RequestFactory.new(attributes) }

      before do
        factory.save
      end

      it 'is valid with given attributes' do
        expect(factory).to be_valid
      end

      it 'creates ont request' do
        expect(Ont::Request.all.count).to eq(1)
        expect(Ont::Request.first.name).to eq('sample 1')
        expect(Ont::Request.first.external_id).to eq('1')
      end

      it 'creates tag_taggable' do
        expect(::TagTaggable.count).to eq(1)
        expect(::TagTaggable.first.tag).to eq(tag_set.tags.first)
        expect(::TagTaggable.first.taggable).to eq(Ont::Request.first)
      end

      it 'creates a container material' do
        expect(factory.save).to be_truthy
        expect(::ContainerMaterial.all.count).to eq(1)
        expect(::ContainerMaterial.first.container).to eq(::Well.where(position: 'A1').first)
        expect(::ContainerMaterial.first.material).to eq(Ont::Request.first)
      end

      it 'validates the tag taggable only once by default' do
        validation_count = 0
        allow_any_instance_of(TagTaggable).to receive(:valid?) { |_| validation_count += 1 }
        factory.save
        expect(validation_count).to eq(1)
      end

      it 'validates the container material join only once by default' do
        validation_count = 0
        allow_any_instance_of(ContainerMaterial).to receive(:valid?) { |_| validation_count += 1 }
        factory.save
        expect(validation_count).to eq(1)
      end

      it 'validates the ONT request only once by default' do
        validation_count = 0
        allow_any_instance_of(Ont::Request).to receive(:valid?) { |_| validation_count += 1 }
        factory.save
        expect(validation_count).to be >= 1
        expect(validation_count).to eq(1)
      end

      it 'validates no children when (validate: false) is passed' do
        validation_count = 0
        allow_any_instance_of(Request).to receive(:valid?) { |_| validation_count += 1 }
        allow_any_instance_of(TagTaggable).to receive(:valid?) { |_| validation_count += 1 }
        allow_any_instance_of(ContainerMaterial).to receive(:valid?) { |_| validation_count += 1 }
        allow_any_instance_of(Ont::Request).to receive(:valid?) { |_| validation_count += 1 }
        allow_any_instance_of(Sample).to receive(:valid?) { |_| validation_count += 1 }
        factory.save(validate: false)
        expect(validation_count).to eq(0)
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

      it 'does not create a join' do
        expect(::ContainerMaterial.all.count).to eq(0)
      end

      it 'does not create a tag taggable' do
        expect(TagTaggable.all.count).to eq(0)
      end
    end
  end
end
