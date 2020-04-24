# frozen_string_literal: true

require "rails_helper"

RSpec.describe 'GraphQL', type: :request do

  context 'get well' do
    context 'when there is a valid well' do
      let!(:well) { create(:well) }

      it 'returns the well with valid ID' do
        post v2_path, params: { query: '{ well(id: 1) { id plateId } }' }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['well']).to include(
          'id' => '1',
          'plateId' => 1
        )
      end

      it 'handles that there is no sample in the well' do
        post v2_path, params: { query: '{ well(id: 1) { id plateId material { ... on Request { id } } } }' }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['well']['material']).to be_nil
      end

      it 'returns null when well invalid ID' do
        post v2_path, params: { query: '{ well(id: 10) { id } }' }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['well']).to be_nil
      end
    end
  end

  context 'get wells' do
    context 'when there are two plates with wells' do
      let!(:plate_1) { create(:plate_with_wells, well_count: 2) }
      let!(:plate_2) { create(:plate_with_wells, well_count: 1) }

      it 'returns all wells' do
        post v2_path, params: { query: '{ wells { id } }' }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['wells'].length).to eq(3)
      end

      it 'returns wells for plate 1' do
        post v2_path, params: { query: "{ wells(plateId: #{plate_1.id}) { plateId } }" }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['wells'].length).to eq(2)
        expect(json['data']['wells'].map { |well| well['plateId'] }).to contain_exactly(plate_1.id, plate_1.id)
      end

      it 'returns well for plate 2' do
        post v2_path, params: { query: "{ wells(plateId: #{plate_2.id}) { plateId } }" }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['wells'].length).to eq(1)
        expect(json['data']['wells'].first['plateId']).to eq(plate_2.id)
      end

      it 'returns no well for invalid plate ID' do
        post v2_path, params: { query: "{ wells(plateId: 10) { id } }" }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['wells'].length).to eq(0)
      end
    end
  end

end
