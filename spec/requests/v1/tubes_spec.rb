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
      create(:tube, material: sample)
      get v1_tubes_path, headers: headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    context 'when material is a sample' do
      let!(:sample1) { create(:sample)}
      let!(:sample2) { create(:sample)}
      let!(:tube1) { create(:tube, material: sample1)}
      let!(:tube2) { create(:tube, material: sample2)}

      it 'returns the correct attributes' do
        get v1_tubes_path, headers: headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'][0]['attributes']['barcode']).to eq(tube1.barcode)
        expect(json['data'][0]['relationships']['material']).to be_present
        expect(json['data'][0]['relationships']['material']['data']['type']).to eq("samples")
        expect(json['data'][0]['relationships']['material']['data']['id']).to eq(tube1.material.id.to_s)

        expect(json['data'][1]['attributes']['barcode']).to eq(tube2.barcode)
        expect(json['data'][1]['relationships']['material']).to be_present
        expect(json['data'][1]['relationships']['material']['data']['type']).to eq("samples")
        expect(json['data'][1]['relationships']['material']['data']['id']).to eq(tube2.material.id.to_s)
      end
    end

    context 'when material is a library' do
      let!(:library1) { create(:library) }
      let!(:library2) { create(:library) }
      let!(:tube1) { create(:tube, material: library1)}
      let!(:tube2) { create(:tube, material: library2)}

      it 'returns the correct attributes' do
        get v1_tubes_path, headers: headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'][0]['attributes']['barcode']).to eq(tube1.barcode)
        expect(json['data'][0]['relationships']['material']).to be_present
        expect(json['data'][0]['relationships']['material']['data']['type']).to eq("libraries")
        expect(json['data'][0]['relationships']['material']['data']['id']).to eq(tube1.material.id.to_s)

        expect(json['data'][1]['attributes']['barcode']).to eq(tube2.barcode)
        expect(json['data'][1]['relationships']['material']).to be_present
        expect(json['data'][1]['relationships']['material']['data']['type']).to eq("libraries")
        expect(json['data'][1]['relationships']['material']['data']['id']).to eq(tube2.material.id.to_s)
      end
    end
  end

end
