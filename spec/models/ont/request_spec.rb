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

  it 'returns sample name' do
    request = create(:ont_request)
    expect(request.sample_name).to be_present
    expect(request.sample_name).to eq(request.sample.name)
  end

  it 'returns sample species' do
    request = create(:ont_request)
    expect(request.sample_species).to be_present
    expect(request.sample_species).to eq(request.sample.species)
  end

  it 'is not valid without external study id' do
    request = build(:ont_request, external_study_id: nil)
    expect(request).not_to be_valid
  end
end
