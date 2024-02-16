# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TubesController' do
  let(:pipeline_name)       { 'pacbio' }
  let(:other_pipeline_name) { 'ont' }

  it_behaves_like 'tubes'

  describe '#get?include=pools' do
    let!(:pacbio_pool) { create(:pacbio_pool, tube: create(:tube)) }

    it 'returns a response' do
      get "#{v1_pacbio_tubes_path}?include=pools", headers: json_api_headers

      expect(response).to have_http_status(:success)
    end

    it 'included pools' do
      get "#{v1_pacbio_tubes_path}?include=pools", headers: json_api_headers

      expect(find_included_resource(type: 'pools', id: pacbio_pool.id)).to be_present
    end
  end

  describe '#get?include=library' do
    let!(:pacbio_library) { create(:pacbio_library, tube: create(:tube)) }

    it 'returns a response' do
      get "#{v1_pacbio_tubes_path}?include=libraries", headers: json_api_headers

      expect(response).to have_http_status(:success)
    end

    it 'included library' do
      get "#{v1_pacbio_tubes_path}?include=libraries", headers: json_api_headers

      expect(find_included_resource(type: 'libraries', id: pacbio_library.id)).to be_present
    end
  end

  describe 'filter' do
    context 'when filtering by barcode' do
      let!(:tubes_with_request) { create_list(:tube_with_pacbio_request, 2) }

      it 'returns the correct tube' do
        barcode = tubes_with_request[0].barcode
        get "#{v1_pacbio_tubes_path}?filter[barcode]=#{barcode}", headers: json_api_headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'][0]['attributes']['barcode']).to eq barcode
      end

      it 'accepts case-insensitive barcode' do
        barcode = tubes_with_request[0].barcode
        downcased = barcode.downcase
        get "#{v1_pacbio_tubes_path}?filter[barcode]=#{downcased}", headers: json_api_headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'][0]['attributes']['barcode']).to eq barcode
      end
    end

    context 'filtering by barcodes' do
      let!(:tubes_with_library) { create_list(:tube_with_pacbio_library, 4) }

      it 'returns the correct tubes' do
        barcodes = tubes_with_library.map(&:barcode)[0..1]
        get "#{v1_pacbio_tubes_path}?filter[barcode]=#{barcodes.join(',')}", headers: json_api_headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'].length).to eq(barcodes.length)
        expect(json['data'][0]['attributes']['barcode']).to eq barcodes[0]
        expect(json['data'][1]['attributes']['barcode']).to eq barcodes[1]
      end

      it 'accepts multiple case-insensitive barcodes' do
        barcodes = tubes_with_library.map(&:barcode)[0..1]
        downcased = barcodes.map(&:downcase)
        get "#{v1_pacbio_tubes_path}?filter[barcode]=#{downcased.join(',')}", headers: json_api_headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'].length).to eq(barcodes.length)
        expect(json['data'][0]['attributes']['barcode']).to eq barcodes[0]
        expect(json['data'][1]['attributes']['barcode']).to eq barcodes[1]
      end
    end
  end
end
