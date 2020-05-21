require 'rails_helper'

RSpec.describe Ont::Request, type: :model, ont: true do
  context 'material' do
    let(:material_model) { :ont_request }
    it_behaves_like 'material'
  end

  context 'taggable' do
    let(:taggable_model) { :ont_request_with_tags }
    it_behaves_like 'taggable'
  end

  it 'must have a name' do
    request = build(:ont_request, name: nil)
    expect(request).not_to be_valid
  end

  it 'must have an external_id' do
    request = build(:ont_request, external_id: nil)
    expect(request).not_to be_valid
  end

  context 'resolve' do
    it 'returns expected includes_args' do
      expect(Ont::Request.includes_args).to eq([
        container_material: :container,
        library: Ont::Library.includes_args(:requests),
        tags: :tag_set ])
    end

    it 'removes container from includes_args' do
      expect(Ont::Request.includes_args(:container_material)).to eq([
        library: Ont::Library.includes_args(:requests),
        tags: :tag_set
      ])
    end

    it 'removes library from includes_args' do
      expect(Ont::Request.includes_args(:library)).to eq([container_material: :container, tags: :tag_set])
    end

    it 'removes tags from includes_args' do
      expect(Ont::Request.includes_args(:tags)).to eq([
        container_material: :container,
        library: Ont::Library.includes_args(:requests)
      ])
    end
  end
end
