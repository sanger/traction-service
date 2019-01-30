require "rails_helper"

RSpec.describe 'EnzymesController', type: :request do
  let(:headers) do
    {
      'Content-Type' => 'application/vnd.api+json',
      'Accept' => 'application/vnd.api+json'
    }
  end

  context '#get' do
    let!(:enzyme1) { create(:enzyme) }
    let!(:enzyme2) { create(:enzyme) }

    it 'returns a list of enzymes' do
      get v1_enzymes_path, headers: headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get v1_enzymes_path, headers: headers

      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['attributes']['name']).to eq(enzyme1.name)
      expect(json['data'][1]['attributes']['name']).to eq(enzyme2.name)
    end

  end

end
