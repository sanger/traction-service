require "rails_helper"

RSpec.describe 'TubesController', type: :request do

  context '#get' do
    it 'returns a list of tubes' do
      create_list(:tube, 2)
      get v1_tubes_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    context 'when material is a request' do
      let!(:request1) { create(:pacbio_request)}
      let!(:request2) { create(:saphyr_request)}
      let!(:tube1) { create(:tube, material: request1)}
      let!(:tube2) { create(:tube, material: request2)}

      it 'returns the correct attributes' do
        get v1_tubes_path, headers: json_api_headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'][0]['attributes']['barcode']).to eq(tube1.barcode)
        expect(json['data'][0]['relationships']['material']).to be_present
        expect(json['data'][0]['relationships']['material']['data']['type']).to eq("requests")
        expect(json['data'][0]['relationships']['material']['data']['id']).to eq(tube1.material.id.to_s)

        expect(json['data'][1]['attributes']['barcode']).to eq(tube2.barcode)
        expect(json['data'][1]['relationships']['material']).to be_present
        expect(json['data'][1]['relationships']['material']['data']['type']).to eq("requests")
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

    describe 'filter' do
      context 'when filtering by barcode' do
        let(:tubes_with_request) { create_list(:tube, 2)}

        it 'returns the correct tube' do
          barcode = tubes_with_request[0].barcode
          get "#{v1_tubes_path}?filter[barcode]=#{barcode}", headers: json_api_headers
          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)
          expect(json['data'].length).to eq(1)
          expect(json['data'][0]["attributes"]["barcode"]).to eq barcode
        end
      end

      context 'filtering by barcodes' do
        let(:tubes) { create_list(:tube, 4)}

        it 'returns the correct tubes' do
          barcodes = tubes.map(&:barcode)[0..1]
          get "#{v1_tubes_path}?filter[barcode]=#{barcodes.join(',')}", headers: json_api_headers
          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)
          expect(json['data'].length).to eq(barcodes.length)
          expect(json['data'][0]["attributes"]["barcode"]).to eq barcodes[0]
          expect(json['data'][1]["attributes"]["barcode"]).to eq barcodes[1]
        end
      end
    end

    describe 'filter and include' do
      context 'when including material and the material is a request' do
        let(:tubes_with_request) { create_list(:tube, 2)}

        it 'returns the request data' do
          tube = tubes_with_request[0]
          get "#{v1_tubes_path}?filter[barcode]=#{tube.barcode}&include=material", headers: json_api_headers

          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)
          expect(json['included'][0]['id']).to eq tube.material .id.to_s
          expect(json['included'][0]['type']).to eq "requests"
          expect(json['included'][0]['attributes']['external_study_id']).to eq tube.material.external_study_id
          expect(json['included'][0]['attributes']['sample_name']).to eq tube.material.sample.name
          expect(json['included'][0]['attributes']['barcode']).to eq tube.barcode

          expect(json['data'][0]['relationships']['material']['data']['type']).to eq 'requests'
          expect(json['data'][0]['relationships']['material']['data']['id']).to eq tube.material.id.to_s
        end
      end

      # context 'when including material and the material is a library' do
      #   let(:tubes_with_request) { create_list(:tube, 2)}
      #
      #   it 'returns the request data' do
      #     tube = tubes_with_request[0]
      #     get "#{v1_tubes_path}?filter[barcode]=#{tube.barcode}&include=material", headers: json_api_headers
      #
      #     expect(response).to have_http_status(:success)
      #     json = ActiveSupport::JSON.decode(response.body)
      #     expect(json['included'][0]['id']).to eq tube.material .id.to_s
      #     expect(json['included'][0]['type']).to eq "requests"
      #
      #     debugger
      #
      #     expect(json['included'][0]['attributes']['external_study_id']).to eq tube.material.external_study_id
      #     expect(json['included'][0]['relationships']['material']['data'][0]['id']).to eq chip.flowcells[0].id.to_s
      #     expect(json['included'][0]['relationships']['material']['data'][1]['id']).to eq chip.flowcells[1].id.to_s
      #   end
      # end
    end

  end

end
