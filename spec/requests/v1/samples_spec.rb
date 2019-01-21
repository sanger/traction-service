require "rails_helper"

RSpec.describe 'SamplesController', type: :request do

  let(:headers) do
    {
      'Content-Type' => 'application/vnd.api+json',
      'Accept' => 'application/vnd.api+json'
    }
  end

  context '#get' do
    let!(:samples) { create_list(:sample, 5)}
    let!(:library1) { create(:library, sample: samples[0])}
    let!(:library2) { create(:library, sample: samples[0])}

    it 'returns a list of samples' do
      get v1_samples_path, headers: headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(5)
      expect(json['data'][0]["attributes"]["name"]).to eq(samples[0].name)
      expect(json['data'][0]["attributes"]["state"]).to eq(samples[0].state)
      expect(json['data'][0]["attributes"]["sequencescape-request-id"]).to eq(samples[0].sequencescape_request_id)
      expect(json['data'][0]["attributes"]["species"]).to eq(samples[0].species)

      expect(json['data'][0]['relationships']['libraries']['data'][0]['type']).to eq("libraries")
      expect(json['data'][0]['relationships']['libraries']['data'].length).to eq(samples[0].libraries.length)

      expect(json['data'][0]['relationships']['tube']).to be_present
      # expect(json['data'][0]['relationships']['tube']['data']['type']).to eq("tubes")
      # expect(json['data'][0]['relationships']['tube']['data']['id']).to eq(libraries[0].tube_id.to_s)
    end
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

    context 'on success' do
      it 'has a created status' do
        post v1_samples_path, params: body, headers: headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a sample' do
        expect { post v1_samples_path, params: body, headers: headers }.to change { Sample.count }.by(1)
      end

      it 'creates a sample with a tube' do
        post v1_samples_path, params: body, headers: headers
        expect(Sample.last.tube).to be_present
        tube_id = Sample.last.tube.id
        expect(Tube.find(tube_id).material).to eq Sample.last
      end
    end

    context 'on failure' do
      context 'when the sample name already exists' do
        it 'has unprocessable entity status' do
          post v1_samples_path, params: body, headers: headers
          post v1_samples_path, params: body, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)["errors"].length).to eq 1
        end
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

    context 'on success' do
      context 'when the sample names do not exist' do
        it 'creates the samples and returns an appropriate response' do
          expect { post v1_samples_path, params: body, headers: headers }.to change(Sample, :count).by(2)
          expect(response).to have_http_status(:created)

          json = ActiveSupport::JSON.decode(response.body)
          expect(json['data'].length).to eq(2)
          sample = json['data'].first['attributes']
          expect(sample['name']).to eq(attributes[0][:name])
          expect(sample['state']).to eq(attributes[0][:state])
          expect(sample['sequencescape-request-id']).to eq(attributes[0][:sequencescape_request_id].to_i)
          expect(sample['species']).to eq(attributes[0][:species])
        end
      end
    end

  end

end
