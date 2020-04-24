# frozen_string_literal: true

require "rails_helper"

RSpec.describe 'GraphQL', type: :request do
  context 'get plates' do
    context 'no plates' do
      it 'returns empty plates' do
        post v2_path, params: { query: '{ plates { id } }' }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['plates'].length).to eq(0)
      end
    end

    context 'some plates' do
      let!(:plate_1) { create(:plate) }
      let!(:plate_2) { create(:plate) }
      let!(:plate_3) { create(:plate) }

      it 'returns all plates' do
        post v2_path, params: { query: '{ plates { id } }' }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['plates'].length).to eq(3)
      end
    end

    context 'a plate with samples' do
      let!(:plate) do
        create(:plate_with_ont_samples, samples: [
            { position: 'A1', name: 'Sample in A1' },
            { position: 'H12', name: 'Sample in H12' }
          ]
        )
      end

      it 'returns plate with nested sample' do
        post v2_path, params: { query: '{ plates { wells { material { ... on Request { sample { name } } } } } }' }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['plates'].length).to eq(1)
        expect(json['data']['plates'].first).to include(
          'wells' => [
            {
              'material' => {
                'sample' => {
                  'name' => 'Sample in A1'
                }
              }
            },
            {
              'material' => {
                'sample' => {
                  'name' => 'Sample in H12'
                }
              }
            }
          ]
        )
      end
    end
  end

  context 'create plate' do
    it 'creates a plate with provided parameters' do

    end

    it 'provides an error when wrong parameters given' do

    end
  end
end
