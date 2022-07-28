# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RequestsController', type: :request, pacbio: true do
  describe '#get' do
    let!(:requests) { create_list(:pacbio_request, 2) }

    it 'returns a list of requests' do
      get v1_pacbio_requests_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      request = requests.first

      get v1_pacbio_requests_path, headers: json_api_headers
      json = ActiveSupport::JSON.decode(response.body)

      Pacbio.request_attributes.each do |attribute|
        expect(json['data'][0]['attributes'][attribute.to_s]).to eq(request.send(attribute))
      end

      expect(json['data'][0]['attributes']['sample_name']).to eq(request.sample_name)
    end
  end

  describe '#destroy' do
    let!(:request) { create(:pacbio_request) }

    context 'on success' do
      it 'returns the correct status' do
        delete "#{v1_pacbio_requests_path}/#{request.id}", headers: json_api_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'destroys the request' do
        expect do
          delete "#{v1_pacbio_requests_path}/#{request.id}", headers: json_api_headers
        end.to change(Pacbio::Request, :count).by(-1)
      end
    end

    context 'on failure' do
      it 'does not delete the request' do
        delete "#{v1_pacbio_requests_path}/fakerequest", headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        delete "#{v1_pacbio_requests_path}/fakerequest", headers: json_api_headers
        data = JSON.parse(response.body)['data']
        expect(data['errors']).to be_present
      end
    end
  end

  describe '#update' do
    let!(:request) { create(:pacbio_request) }

    let(:body) do
      {
        data: {
          id: request.id.to_s,
          type: 'requests',
          attributes: request.attributes.slice(:library_type, :estimate_of_gb_required,
                                               :number_of_smrt_cells, :cost_code, :external_study_id).merge(cost_code: 'fraud')
        }
      }.to_json
    end

    it 'returns success status' do
      patch v1_pacbio_request_path(request), params: body, headers: json_api_headers
      expect(response).to have_http_status(:success), response.body
    end

    it 'updates the request' do
      patch v1_pacbio_request_path(request), params: body, headers: json_api_headers
      request.reload
      expect(request.cost_code).to eq('fraud')
    end

    it 'publishes a message' do
      # This might be overkill but wanted to ensure the right thing is happening
      expect(Messages).to receive(:publish).with(request.sequencing_plates,
                                                 having_attributes(pipeline: 'pacbio'))
      patch v1_pacbio_request_path(request), params: body, headers: json_api_headers
    end
  end

  describe '#update - failure' do
    let!(:request) { create(:pacbio_request) }

    let(:body) do
      {
        data: {
          id: request.id.to_s,
          type: 'requests',
          attributes: request.attributes.slice(:library_type, :estimate_of_gb_required,
                                               :number_of_smrt_cells, :cost_code, :external_study_id).merge(external_study_id: nil)
        }
      }.to_json
    end

    it 'returns unprocessable entity status' do
      patch v1_pacbio_request_path(request), params: body, headers: json_api_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'does not publish the message' do
      expect(Messages).not_to receive(:publish)
      patch v1_pacbio_request_path(request), params: body, headers: json_api_headers
    end
  end
end
