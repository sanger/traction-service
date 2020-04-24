# frozen_string_literal: true

require "rails_helper"

RSpec.describe 'GraphQL', type: :request do

  context 'get well' do
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

    it 'returns null when well invalid ID' do
      post v2_path, params: { query: '{ well(id: 10) { id } }' }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['well']).to be_nil
    end
  end

  context 'get wells' do
    let!(:plate_1) { create(:plate) }
    let!(:plate_2) { create(:plate) }

    let!(:well_1) do
      create(:well) do |well|
        well.update(plate: plate_1)
      end
    end

    let!(:well_2) do
      create(:well) do |well|
        well.update(plate: plate_1)
      end
    end

    let!(:well_3) do
      create(:well) do |well|
        well.update(plate: plate_2)
      end
    end

    it 'returns all wells' do
      post v2_path, params: { query: '{ wells { id } }' }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['wells'].length).to eq(3)
    end

    it 'returns wells for plate 1' do
      post v2_path, params: { query: "{ wells(plateId: #{plate_1.id}) { id plateId } }" }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['wells'].length).to eq(2)
      expect(json['data']['wells'].map { |well| well['id'] }).to contain_exactly(well_1.id.to_s, well_2.id.to_s)
      expect(json['data']['wells'].map { |well| well['plateId'] }).to contain_exactly(plate_1.id, plate_1.id)
    end

    it 'returns well for plate 2' do
      post v2_path, params: { query: "{ wells(plateId: #{plate_2.id}) { id plateId } }" }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['wells'].length).to eq(1)
      expect(json['data']['wells'].first['id']).to eq(well_3.id.to_s)
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
