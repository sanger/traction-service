# frozen_string_literal: true

require 'rails_helper'

require './spec/support/json_matcher'

RSpec.describe 'ReceptionsController' do
  before do
    Flipper.enable(:dpl_277_enable_general_reception)

    Broker::Handle.class_eval do
      def test_received_messages
        @test_received_messages ||= []
      end

      def publish(message)
        test_received_messages.push(message.payload)
      end
    end
  end

  describe '#post' do
    let!(:library_type) { create(:library_type, :ont) }
    let!(:data_type) { create(:data_type, :ont) }

    context 'with a valid payload' do
      let(:object_body) do
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
        }
      end
      let(:body) do
        object_body.to_json
      end

      it 'has a created status' do
        post v1_receptions_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created), response.body
      end

      context 'when receiving a change on labware' do
        let(:changed_body) do
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
                    sample: attributes_for(:sample).merge({
                                                            species: 'blablabla'
                                                          }),
                    container: { type: 'tubes', barcode: 'NT1' }
                  }
                ]
              }
            }
          }.to_json
        end

        it 'rejects the request' do
          post v1_receptions_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created), response.body

          post v1_receptions_path, params: changed_body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity), response.body
        end
      end

      context 'when receiving an update on labware' do
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
                    container: { type: 'wells', barcode: 'NT1', position: 'A1' }
                  }
                ]
              }
            }
          }.to_json
        end
        let(:updated_body) do
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
                    container: { type: 'wells', barcode: 'NT1', position: 'A2' }
                  }
                ]
              }
            }
          }.to_json
        end

        it 'can accept an update on labware' do
          post v1_receptions_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created), response.body
          post v1_receptions_path, params: updated_body, headers: json_api_headers
          expect(response).to have_http_status(:created), response.body
        end
      it 'publishes a message' do
        expect(Messages).to receive(:publish).twice
        post v1_receptions_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:success), response.body
        expect(Broker::Handle.test_received_messages.length).to eq(2)
        assert match_json(Broker::Handle.test_received_messages[0],
                          {
                            'lims' => 'Traction', 'sample' => {
                              'common_name' => 'human',
                              'last_updated' => /.*/,
                              'id_sample_lims' => /\d/,
                              'uuid_sample_lims' => /.*/,
                              'name' => /.*/
                            }
                          })
        assert match_json(Broker::Handle.test_received_messages[1],
                          {
                            'lims' => 'Traction', 'stock_resource' => {
                              'stock_resource_id' => /\d/,
                              'labware_coordinate' => nil,
                              'human_barcode' => 'NT1',
                              'machine_barcode' => 'NT1',
                              'labware_type' => 'tube',
                              'created_at' => /.*/,
                              'updated_at' => /.*/,
                              'samples' => [
                                {
                                  'sample_uuid' => /.*/,
                                  'study_uuid' => /.*/
                                }
                              ]
                            }
                          })
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
