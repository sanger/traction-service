# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ont::RequestFactory, type: :model, ont: true do
  let(:tag_set_name) { 'OntWell96Samples' }
  let(:tag_set) { create(:tag_set_with_tags, name: tag_set_name) }

  before do
    allow(Pipelines::ConstantsAccessor)
      .to receive(:ont_covid_pcr_tag_set_name)
      .and_return(tag_set_name)
  end

  context '#initialise' do
    it 'is not valid if given no attributes' do
      factory = Ont::RequestFactory.new()
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

    it 'is not valid if the generated ont request is not valid' do
      # request attributes should include a name
      attributes = {
        external_id: '1',
        tag_oligoo: tag_set.tags.first.oligo
      }
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

    it 'is not valid if no matching tag exists' do
      attributes = {
        name: 'sample 1',
        external_id: '1',
        tag_oligo: 'NOT_AN_OLIGO'
      }
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

    it 'is not valid if the tag is not in the correct tag set' do
      wrong_tag_set = create(:tag_set_with_tags, name: 'WrongTagSet')
      attributes = {
        name: 'sample 1',
        external_id: '1',
        tag_oligo: wrong_tag_set.tags.first.oligo
      }
      factory = Ont::RequestFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end
  end

  context '#bulk_insert_serialise' do
    let(:bulk_insert_serialiser) { double() }

    context 'valid build' do
      let(:attributes) do {
          name: 'sample 1',
          external_id: '1',
          tag_oligo: tag_set.tags.first.oligo
        }
      end
      let(:factory) { Ont::RequestFactory.new(attributes) }
      let(:response) { 'ont request data' }

      before do
        allow(bulk_insert_serialiser).to receive(:ont_request_data).with(an_instance_of(Ont::Request), tag_set.tags.first.id).and_return(response)
      end

      it 'is valid with given attributes' do
        expect(factory).to be_valid
      end

      it 'has expected response' do
        expect(factory.bulk_insert_serialise(bulk_insert_serialiser)).to eq(response)
      end

      it 'validates the ONT request only once by default' do
        validation_count = 0
        allow_any_instance_of(Ont::Request).to receive(:valid?) { |_| validation_count += 1 }
        factory.bulk_insert_serialise(bulk_insert_serialiser)
        expect(validation_count).to be >= 1
        expect(validation_count).to eq(1)
      end

      it 'validates no children when (validate: false) is passed' do
        validation_count = 0
        allow_any_instance_of(Ont::Request).to receive(:valid?) { |_| validation_count += 1 }
        factory.bulk_insert_serialise(bulk_insert_serialiser, validate: false)
        expect(validation_count).to eq(0)
      end
    end

    context 'invalid build' do
      let(:factory) { Ont::RequestFactory.new({}) }

      it 'is invalid' do
        expect(factory).to_not be_valid
      end

      it 'returns false' do
        invalid_response = factory.bulk_insert_serialise(bulk_insert_serialiser)
        expect(invalid_response).to be_falsey
      end
    end
  end
end
