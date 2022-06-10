# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ReceptionsController', type: :request do
  describe '#post' do
    let(:library_type) { create :library_type, :ont }
    let(:data_type) { create :data_type, :ont }

    let(:body) do
      {
        data: {
          type: 'receptions',
          attributes: {
            source: 'traction-ui.sequencescape',
            requests: [
              {
                request: attributes_for(:ont_request).merge(
                  library_type: library_type.name,
                  data_type: data_type.name
                ),
                sample: attributes_for(:sample),
                container: { type: 'tube', barcode: 'NT1' }
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
end
