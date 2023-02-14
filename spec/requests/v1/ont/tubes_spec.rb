# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TubesController' do
  let(:pipeline_name)       { 'ont' }
  let(:other_pipeline_name) { 'pacbio' }

  context 'tubes' do
    it 'returns a list' do
      create_list(:tube_with_ont_library, 3)
      create_list(:tube_with_pacbio_library, 4)

      get v1_ont_tubes_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(3)
    end
  end

  describe 'filter' do
    context 'when filtering by barcode' do
      let(:tubes_with_request) { create_list(:tube_with_ont_request, 2) }

      it 'returns the correct tube' do
        barcode = tubes_with_request[0].barcode
        get "#{v1_ont_tubes_path}?filter[barcode]=#{barcode}", headers: json_api_headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'][0]['attributes']['barcode']).to eq barcode
      end

      it 'accepts case-insensitive barcode' do
        barcode = tubes_with_request[0].barcode
        downcased = barcode.downcase
        get "#{v1_ont_tubes_path}?filter[barcode]=#{downcased}", headers: json_api_headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'][0]['attributes']['barcode']).to eq barcode
      end
    end

    context 'filtering by barcodes' do
      let(:tubes_with_library) { create_list(:tube_with_ont_library, 4) }

      it 'returns the correct tubes' do
        barcodes = tubes_with_library.map(&:barcode)[0..1]
        get "#{v1_ont_tubes_path}?filter[barcode]=#{barcodes.join(',')}", headers: json_api_headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'].length).to eq(barcodes.length)
        expect(json['data'][0]['attributes']['barcode']).to eq barcodes[0]
        expect(json['data'][1]['attributes']['barcode']).to eq barcodes[1]
      end

      it 'accepts multiple case-insensitive barcodes' do
        barcodes = tubes_with_library.map(&:barcode)[0..1]
        downcased = barcodes.map(&:downcase)
        get "#{v1_ont_tubes_path}?filter[barcode]=#{downcased.join(',')}", headers: json_api_headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'].length).to eq(barcodes.length)
        expect(json['data'][0]['attributes']['barcode']).to eq barcodes[0]
        expect(json['data'][1]['attributes']['barcode']).to eq barcodes[1]
      end
    end
  end

  describe '#get?include=pools' do
    before do
      ont_pool
      get "#{v1_ont_tubes_path}?include=pools", headers: json_api_headers
    end

    let(:ont_pool) { create(:ont_pool, tube: create(:tube_with_ont_library)) }

    it 'returns a response' do
      expect(response).to have_http_status(:success)
    end

    it 'included pools' do
      expect(find_included_resource(type: 'pools', id: ont_pool.id)).to be_present
    end
  end

  describe '#get?include=requests' do
    before do
      ont_tube
      get "#{v1_ont_tubes_path}?include=requests", headers: json_api_headers
    end

    let(:ont_tube) { create(:tube_with_ont_request) }

    it 'returns a response' do
      expect(response).to have_http_status(:success)
    end

    it 'included requests' do
      expected_id = ont_tube.ont_requests.first.id
      expect(find_included_resource(type: 'requests', id: expected_id)).to be_present
    end
  end
end
