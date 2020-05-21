# frozen_string_literal: true

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
      expect(Ont::Request.includes_args.flat_map(&:keys))
        .to contain_exactly(:container_material, :library, :tags)
    end

    it 'removes container from includes_args' do
      expect(Ont::Request.includes_args(:container_material).flat_map(&:keys))
        .to_not include(:container_material)
    end

    it 'removes library from includes_args' do
      expect(Ont::Request.includes_args(:library).flat_map(&:keys)).to_not include(:library)
    end

    it 'removes tags from includes_args' do
      expect(Ont::Request.includes_args(:tags).flat_map(&:keys)).to_not include(:tags)
    end
  end
end
