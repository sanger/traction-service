require "rails_helper"

RSpec.describe 'TubesController', type: :request do
  let(:headers) do
    {
      'Content-Type' => 'application/vnd.api+json',
      'Accept' => 'application/vnd.api+json'
    }
  end

  context '#get' do
    let!(:tubes) { create_list(:tube, 5)}

    it 'returns a list of tubes' do
      get v1_tubes_path, headers: headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(5)
    end

    it 'returns the correct attributes' do
      get v1_tubes_path, headers: headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'][0]['attributes']['barcode']).to eq(tubes[0].barcode)
    end
  end

end
