require "rails_helper"

RSpec.describe 'TubesController', type: :request do

  context '#get' do
    it 'returns a list of tubes' do
      sample = create(:sample)
      create(:tube, material: sample)
      create(:tube, material: sample)
      get v1_tubes_path, headers: json_api_headers
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
        get v1_tubes_path, headers: json_api_headers
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
      let!(:library1) { create(:saphyr_library) }
      let!(:library2) { create(:saphyr_library) }
      let!(:tube1) { create(:tube, material: library1)}
      let!(:tube2) { create(:tube, material: library2)}

      skip 'returns the correct attributes' do
        get v1_tubes_path, headers: json_api_headers
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

    describe 'filter by barcode' do

      let(:sample_tubes) { create_list(:tube, 2)}
      let(:library_tubes) { create_list(:tube_with_saphyr_library, 2)}
      let(:other_tubes) {create_list(:tube, 5)}
      let(:barcodes) { sample_tubes.pluck(:barcode).concat(library_tubes.pluck(:barcode))}

      skip 'returns the correct tubes' do
        get "#{v1_tubes_path}?filter[barcode]=#{barcodes.join(',')}", headers: json_api_headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'].length).to eq(barcodes.length)
      end
    end

  end

end
