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
              {
                name: 'Sample1'
              }
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
    let(:body) do
      {
        data: {
          attributes: {
            samples: [
              {
                name: 'Sample1'
              },
              {
                name: 'Sample2'
              },
            ]
          }
        }
      }.to_json
    end

    context 'when the sample names do not exist' do
      it 'creates the samples' do
        expect { post v1_samples_path, params: body, headers: headers }.to change(Sample, :count).by(2)
        expect(response).to have_http_status(:created)
      end
    end
  end
end
