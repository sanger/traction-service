require "rails_helper"

RSpec.describe 'SamplesController', type: :request do

  let(:headers) do
    {
      'Content-Type' => 'application/vnd.api+json',
      'Accept' => 'application/vnd.api+json'
    }
  end

  context 'when creating a single sample' do
    let(:body) do
      {
        data: {
          attributes: {
            samples: [
              attributes_for(:sample)
            ]
          }
        }
      }.to_json
    end

    context 'when the sample name doesnt exist' do
      it 'can create a sample' do
        post v1_samples_path, params: body, headers: headers
        expect(response).to have_http_status(:created)
      end
    end

    context 'when the sample name does exist' do
      it 'cannot create a sample' do
        post v1_samples_path, params: body, headers: headers
        post v1_samples_path, params: body, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["errors"].length).to eq 1
      end
    end
  end

  context 'when creating multiple samples' do

    let(:attributes) { [attributes_for(:sample), attributes_for(:sample)]}
    let(:body) do
      {
        data: {
          attributes: {
            samples: attributes
          }
        }
      }.to_json
    end

    context 'when the sample names do not exist' do
      it 'creates the samples and returns an appropriate response' do
        expect { post v1_samples_path, params: body, headers: headers }.to change(Sample, :count).by(2)
        expect(response).to have_http_status(:created)

        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'].length).to eq(2)
        sample = json['data'].first['attributes']
        expect(sample['name']).to eq(attributes[0][:name])
      end
    end
  end

  context '#get' do
    let!(:samples) { create_list(:sample, 5)}

    it 'returns a list of samples' do
      get v1_samples_path, headers: headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(5)
    end
  end
end
