# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ReceptionsController' do
  before do
    Flipper.enable(:dpl_277_enable_general_reception)
  end

  describe '#post' do
    let!(:library_type) { create(:library_type, :ont) }
    let!(:data_type) { create(:data_type, :ont) }

    context 'with a valid payload' do
      let(:body) do
        {
          data: {
            type: 'receptions',
            attributes: {
              source: 'traction-ui.sequencescape',
              request_attributes: [
                {
                  request: attributes_for(:ont_request).merge(
                    library_type: library_type.name,
                    data_type: data_type.name
                  ),
                  sample: attributes_for(:sample),
                  container: { type: 'tubes', barcode: 'NT1' }
                }
              ]
            }
          }
        }.to_json
      end

      it 'has a created status' do
        post v1_receptions_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created), response.body
      end
    end

    context 'with a invalid payload' do
      let(:body) do
        {
          data: {
            type: 'receptions',
            attributes: {
              source: 'Not_A valid SOURCE!!!',
              request_attributes: [
                {
                  request: attributes_for(:ont_request).merge(
                    library_type: library_type.name,
                    data_type: data_type.name
                  ),
                  sample: attributes_for(:sample),
                  container: { type: 'tubes', barcode: 'NT1' }
                }
              ]
            }
          }
        }.to_json
      end

      it 'has a unprocessable_entity status' do
        post v1_receptions_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'generates a valid json-api error response' do
        post v1_receptions_path, params: body, headers: json_api_headers
        pointer = json.dig('errors', 0, 'source', 'pointer')
        expect(pointer).to eq('/data/attributes/source')
      end
    end

    context 'with a invalid library type' do
      let(:body) do
        {
          data: {
            type: 'receptions',
            attributes: {
              source: 'traction-ui.sequencescape',
              request_attributes: [
                {
                  request: attributes_for(:ont_request).merge(
                    library_type: 'Invalid library type',
                    data_type: data_type.name
                  ),
                  sample: attributes_for(:sample),
                  container: { type: 'tubes', barcode: 'NT1' }
                }
              ]
            }
          }
        }.to_json
      end

      it 'has a unprocessable_entity status' do
        post v1_receptions_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'generates a valid json-api error response' do
        post v1_receptions_path, params: body, headers: json_api_headers
        pointer = json.dig('errors', 0, 'source', 'pointer')
        expect(pointer).to eq('/data/attributes/request_attributes/0/request/library_type')
      end
    end

    context 'with a invalid sample payload' do
      let(:body) do
        {
          data: {
            type: 'receptions',
            attributes: {
              source: 'traction-ui.sequencescape',
              request_attributes: [
                {
                  request: attributes_for(:ont_request).merge(
                    library_type: library_type.name,
                    data_type: data_type.name
                  ),
                  sample: {},
                  container: { type: 'tubes', barcode: 'NT1' }
                }
              ]
            }
          }
        }.to_json
      end

      it 'has a unprocessable_entity status' do
        post v1_receptions_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'generates a valid json-api error response' do
        post v1_receptions_path, params: body, headers: json_api_headers
        pointers = json.fetch('errors').map do |error|
          error.dig('source', 'pointer')
        end
        expect(pointers).to include('/data/attributes/request_attributes/0/sample/name')
        expect(pointers).to include('/data/attributes/request_attributes/0/sample/external_id')
      end
    end

    context 'with a badly structured payload' do
      let(:body) do
        {
          data: {
            type: 'receptions',
            attributes: {
              source: 'traction-ui.sequencescape',
              request_attributes: ''
            }
          }
        }.to_json
      end

      it 'has a bad_request status' do
        post v1_receptions_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
