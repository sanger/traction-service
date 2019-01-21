require "rails_helper"

RSpec.describe 'TubesController', type: :request do
  let(:headers) do
    {
      'Content-Type' => 'application/vnd.api+json',
      'Accept' => 'application/vnd.api+json'
    }
  end

  context '#get' do

    it 'returns a list of tubes' do
      sample = create(:sample)
      create(:tube, material: sample)
      get v1_tubes_path, headers: headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(1)
    end

    context 'when material is a sample' do
      let!(:tubes) { create_list(:tube, 5, :with_sample_material)}

      it 'returns the correct attributes' do
        get v1_tubes_path, headers: headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'][0]['attributes']['barcode']).to eq(tubes[0].barcode)
        expect(json['data'][0]['relationships']['material']).to be_present
        expect(json['data'][0]['relationships']['material']['data']['type']).to eq("samples")
        expect(json['data'][0]['relationships']['material']['data']['id']).to eq(tubes[0].material.id.to_s)
      end
    end

    context 'when material is a library' do
      let!(:tubes) { create_list(:tube, 5, :with_library_material)}

      it 'returns the correct attributes' do
        get v1_tubes_path, headers: headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'][0]['attributes']['barcode']).to eq(tubes[0].barcode)
        expect(json['data'][0]['relationships']['material']).to be_present
        expect(json['data'][0]['relationships']['material']['data']['type']).to eq("libraries")
        expect(json['data'][0]['relationships']['material']['data']['id']).to eq(tubes[0].material.id.to_s)
      end
    end
  end

end
