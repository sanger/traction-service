# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'InstrumentsController' do
  def json
    ActiveSupport::JSON.decode(response.body)
  end

  let!(:minion) { create(:ont_minion) }
  let!(:gridion) { create(:ont_gridion) }
  let!(:promethion) { create(:ont_promethion) }

  describe 'index' do
    before do
      get v1_ont_instruments_path, headers: json_api_headers
    end

    it 'returns a response' do
      expect(response).to have_http_status(:success)
    end

    it 'includes all instruments' do
      expect(json['data'].length).to eq(3)
    end

    it 'includes MinIon instrument type' do
      expect(json['data'][0]['id'].to_i).to eq(minion.id)
      expect(json['data'][0]['attributes']['name']).to eq(minion.name)
      expect(json['data'][0]['attributes']['instrument_type']).to eq(minion.instrument_type)
      expect(json['data'][0]['attributes']['max_number_of_flowcells']).to eq(minion.max_number_of_flowcells)
    end

    it 'includes GridIon instrument type' do
      expect(json['data'][1]['id'].to_i).to eq(gridion.id)
      expect(json['data'][1]['attributes']['name']).to eq(gridion.name)
      expect(json['data'][1]['attributes']['instrument_type']).to eq(gridion.instrument_type)
      expect(json['data'][1]['attributes']['max_number_of_flowcells']).to eq(gridion.max_number_of_flowcells)
    end

    it 'includes PromethIon instrument type' do
      expect(json['data'][2]['id'].to_i).to eq(promethion.id)
      expect(json['data'][2]['attributes']['name']).to eq(promethion.name)
      expect(json['data'][2]['attributes']['instrument_type']).to eq(promethion.instrument_type)
      expect(json['data'][2]['attributes']['max_number_of_flowcells']).to eq(promethion.max_number_of_flowcells)
    end
  end

  describe 'show' do
    it 'returns MinIon instrument type' do
      get "#{v1_ont_instruments_path}/#{minion.id}", headers: json_api_headers
      expect(json['data']['id'].to_i).to eq(minion.id)
      expect(json['data']['attributes']['name']).to eq(minion.name)
      expect(json['data']['attributes']['instrument_type']).to eq(minion.instrument_type)
      expect(json['data']['attributes']['max_number_of_flowcells']).to eq(minion.max_number_of_flowcells)
    end

    it 'returns GridIon instrument type' do
      get "#{v1_ont_instruments_path}/#{gridion.id}", headers: json_api_headers
      expect(json['data']['id'].to_i).to eq(gridion.id)
      expect(json['data']['attributes']['name']).to eq(gridion.name)
      expect(json['data']['attributes']['instrument_type']).to eq(gridion.instrument_type)
      expect(json['data']['attributes']['max_number_of_flowcells']).to eq(gridion.max_number_of_flowcells)
    end

    it 'returns PromethIon instrument type' do
      get "#{v1_ont_instruments_path}/#{promethion.id}", headers: json_api_headers
      expect(json['data']['id'].to_i).to eq(promethion.id)
      expect(json['data']['attributes']['name']).to eq(promethion.name)
      expect(json['data']['attributes']['instrument_type']).to eq(promethion.instrument_type)
      expect(json['data']['attributes']['max_number_of_flowcells']).to eq(promethion.max_number_of_flowcells)
    end
  end
end
