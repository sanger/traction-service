# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::AnnotationResource, type: :resource do
  subject(:annotation_resource) { described_class.new(annotation, nil) }

  before do
    create(:pacbio_smrt_link_version, name: 'v25_revio', default: true)
  end

  let(:annotation_type) { create(:annotation_type) }
  let(:annotatable) { create(:pacbio_revio_run) }
  let(:annotation) do
    create(:annotation,
           annotation_type: annotation_type,
           annotatable: annotatable,
           comment: 'Test comment',
           user: 'tester')
  end

  describe 'attributes' do
    it 'returns the correct comment' do
      expect(annotation_resource.comment).to eq('Test comment')
    end

    it 'returns the correct user' do
      expect(annotation_resource.user).to eq('tester')
    end

    it 'returns the correct annotation_type_id' do
      expect(annotation_resource.annotation_type_id).to eq(annotation_type.id)
    end

    it 'returns the correct annotatable_type and annotatable_id' do
      expect(annotation_resource.annotatable_type).to eq('Pacbio::Run')
      expect(annotation_resource.annotatable_id).to eq(annotatable.id)
    end
  end

  describe 'relationships' do
    it 'defines a has_one relationship with annotation_type' do
      expect(described_class._relationships.keys).to include(:annotation_type)
    end
  end

  describe 'API constraints' do
    it 'raises an error when trying to update' do
      expect { annotation_resource.replace_fields({ comment: 'New comment' }) }
        .to raise_error(JSONAPI::Exceptions::RecordLocked)
    end

    it 'raises an error when trying to delete' do
      expect { annotation_resource.remove }
        .to raise_error(JSONAPI::Exceptions::RecordLocked)
    end
  end
end
