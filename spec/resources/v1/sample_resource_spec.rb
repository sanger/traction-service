# frozen_string_literal: true

# spec/requests/v1/samples_spec.rb
require 'rails_helper'

RSpec.describe 'V1::Samples API', type: :request do
  describe 'GET /v1/samples/:id' do
    let(:sample) { create(:sample, name: 'Sample X', created_at: Time.zone.local(2024, 6, 1)) }

    let(:pacbio_requestable) do
      create(:pacbio_request, external_study_id: '3b1cf0ac-4079-11f0-805f-e2df7c04b5f6', cost_code: 'COST456')
    end

    before do
      create(:request,
             sample: sample,
             requestable_type: 'Pacbio::Request',
             requestable: pacbio_requestable)
    end

    it 'resource include sample name' do
      get "/v1/samples/#{sample.id}"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      attributes = body.dig('data', 'attributes')
      expect(attributes['name']).to eq('Sample X')
    end

    it 'includes pacbio_requests with external_study_id and cost_code' do
      get "/v1/samples/#{sample.id}"

      body = JSON.parse(response.body)
      pacbio_requests = body.dig('data', 'attributes', 'pacbio_requests')

      expect(pacbio_requests).to be_an(Array)
      expect(pacbio_requests.length).to eq(1)

      pacbio = pacbio_requests.first
      expect(pacbio['external_study_id']).to eq('3b1cf0ac-4079-11f0-805f-e2df7c04b5f6')
      expect(pacbio['cost_code']).to eq('COST456')
    end
  end
end
