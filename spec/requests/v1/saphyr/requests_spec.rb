# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RequestsController', saphyr: true do
  describe '#get' do
    let!(:requests) { create_list(:saphyr_request, 2) }

    it 'returns a list of requests' do
      get v1_saphyr_requests_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      request = requests.first

      get v1_saphyr_requests_path, headers: json_api_headers
      json = ActiveSupport::JSON.decode(response.body)

      Saphyr.request_attributes.each do |attribute|
        expect(json['data'][0]['attributes'][attribute.to_s]).to eq(request.send(attribute))
      end

      expect(json['data'][0]['attributes']['sample_name']).to eq(request.sample_name)
    end
  end

  describe '#create' do
    context 'when creating a single request' do
      context 'on success' do
        let(:body) do
          {
            data: {
              type: 'requests',
              attributes: {
                requests: [
                  {
                    request: attributes_for(:saphyr_request),
                    sample: attributes_for(:sample),
                    tube: { barcode: 'custom' }
                  }
                ]
              }
            }
          }.to_json
        end

        it 'has a created status' do
          post v1_saphyr_requests_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created)
        end

        it 'creates a request' do
          expect do
            post v1_saphyr_requests_path, params: body, headers: json_api_headers
          end.to change(Saphyr::Request, :count).by(1)
        end

        it 'creates a sample' do
          expect do
            post v1_saphyr_requests_path, params: body, headers: json_api_headers
          end.to change(Sample, :count).by(1)
        end
      end

      context 'on failure' do
        let(:body) do
          {
            data: {
              attributes: {
                requests: [
                  {
                    request: attributes_for(:saphyr_request),
                    sample: attributes_for(:sample).except(:name),
                    tube: { barcode: 'custom' }
                  }
                ]
              }
            }
          }.to_json
        end

        it 'has an unprocessable entity status' do
          post v1_saphyr_requests_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'cannot create a request' do
          expect do
            post v1_saphyr_requests_path, params: body,
                                          headers: json_api_headers
          end.not_to change(Saphyr::Request, :count)
        end

        it 'has an error message' do
          post v1_saphyr_requests_path, params: body, headers: json_api_headers
          expect(JSON.parse(response.body)['data']).not_to be_empty
        end
      end

      context 'when creating multiple requests' do
        context 'on success' do
          context 'when the sample does exist' do
            let(:body) do
              {
                data: {
                  attributes: {
                    requests: [
                      { request: attributes_for(:saphyr_request), sample: attributes_for(:sample) },
                      { request: attributes_for(:saphyr_request), sample: attributes_for(:sample) }
                    ]
                  }
                }
              }.to_json
            end

            it 'can create requests' do
              post v1_saphyr_requests_path, params: body, headers: json_api_headers
              expect(response).to have_http_status(:created)
            end

            it 'will have the correct number of requests' do
              expect do
                post v1_saphyr_requests_path, params: body,
                                              headers: json_api_headers
              end.to change(Saphyr::Request, :count).by(2)
            end
          end
        end
      end
    end
  end

  describe '#destroy' do
    let!(:request) { create(:saphyr_request) }

    context 'on success' do
      it 'returns the correct status' do
        delete "/v1/saphyr/requests/#{request.id}", headers: json_api_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'destroys the request' do
        expect { delete "/v1/saphyr/requests/#{request.id}", headers: json_api_headers }.to change(Saphyr::Request, :count).by(-1)
      end
    end

    context 'on failure' do
      it 'does not delete the request' do
        delete '/v1/saphyr/requests/fakerequest', headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        delete '/v1/saphyr/requests/fakerequest', headers: json_api_headers
        data = JSON.parse(response.body)['data']
        expect(data['errors']).to be_present
      end
    end
  end
end
