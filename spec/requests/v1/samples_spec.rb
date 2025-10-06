# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SamplesController' do
  describe '#get' do
    let!(:sample1) { create(:sample, number_of_donors: 1) }
    let!(:sample2) { create(:sample) }

    it 'returns a list of samples' do
      get v1_samples_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
      expect(json['data'][0]['attributes']['name']).to eq(sample1.name)
      expect(json['data'][0]['attributes']['external_id']).to eq(sample1.external_id)
      expect(json['data'][0]['attributes']['species']).to eq(sample1.species)
      expect(json['data'][0]['attributes']['created_at']).to eq(sample1.created_at.to_fs(:us))
      # Number of donors only exist on compound samples, but we want to check it can be exposed in the api
      expect(json['data'][0]['attributes']['number_of_donors']).to eq(sample1.number_of_donors)
      expect(json['data'][0]['attributes']['deactivated_at']).to be_nil

      expect(json['data'][1]['attributes']['name']).to eq(sample2.name)
      expect(json['data'][1]['attributes']['external_id']).to eq(sample2.external_id)
      expect(json['data'][1]['attributes']['species']).to eq(sample2.species)
      expect(json['data'][1]['attributes']['created_at']).to eq(sample2.created_at.to_fs(:us))
      expect(json['data'][1]['attributes']['number_of_donors']).to be_nil
      expect(json['data'][1]['attributes']['deactivated_at']).to be_nil
    end
  end
end
