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
        data = response.parsed_body['data']
        expect(data['errors']).to be_present
      end
    end
  end
end
