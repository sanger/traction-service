# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SamplesController', type: :request do

  context '#get' do
    let!(:sample1) { create(:sample)}
    let!(:sample2) { create(:sample)}
    let!(:library1) { create(:library, sample: sample1)}
    let!(:library2) { create(:library, sample: sample2)}
    let!(:tube1) { create(:tube, material: sample1)}
    let!(:tube2) { create(:tube, material: sample2)}

    it 'returns a list of samples' do
      get v1_samples_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
      expect(json['data'][0]["attributes"]["name"]).to eq(sample1.name)
      expect(json['data'][0]["attributes"]["external_id"]).to eq(sample1.external_id)
      expect(json['data'][0]["attributes"]["species"]).to eq(sample1.species)
      expect(json['data'][0]["attributes"]["barcode"]).to eq(sample1.tube.barcode)
      expect(json['data'][0]["attributes"]["created_at"]).to eq(sample1.created_at.strftime("%m/%d/%Y %I:%M"))
      expect(json['data'][0]["attributes"]["deactivated_at"]).to eq(nil)

      expect(json['data'][1]["attributes"]["name"]).to eq(sample2.name)
      expect(json['data'][1]["attributes"]["external_id"]).to eq(sample2.external_id)
      expect(json['data'][1]["attributes"]["species"]).to eq(sample2.species)
      expect(json['data'][1]["attributes"]["barcode"]).to eq(sample2.tube.barcode)
      expect(json['data'][1]["attributes"]["created_at"]).to eq(sample2.created_at.strftime("%m/%d/%Y %I:%M"))
      expect(json['data'][1]["attributes"]["deactivated_at"]).to eq(nil)

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
        post v1_samples_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a sample' do
        expect { post v1_samples_path, params: body, headers: json_api_headers }.to change { Sample.count }.by(1)
      end

      it 'creates a sample with a tube' do
        post v1_samples_path, params: body, headers: json_api_headers
        expect(Sample.last.tube).to be_present
        tube_id = Sample.last.tube.id
        expect(Tube.find(tube_id).material).to eq Sample.last
      end
    end

    context 'on failure' do
      context 'when the sample name already exists' do
        it 'has unprocessable entity status' do
          post v1_samples_path, params: body, headers: json_api_headers
          post v1_samples_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)["errors"].length).to eq 1
        end
      end
    end
  end

  context 'when creating multiple samples' do
    let(:attributes) { [attributes_for(:sample), attributes_for(:sample)] }
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
          expect { post v1_samples_path, params: body, headers: json_api_headers }.to change(Sample, :count).by(2)
          expect(response).to have_http_status(:created)

          json = ActiveSupport::JSON.decode(response.body)
          expect(json['data'].length).to eq(2)
          sample = json['data'].first['attributes']
          expect(sample['name']).to eq(attributes[0][:name])
          expect(sample['external_id']).to eq(attributes[0][:external_id].to_i)
          expect(sample['species']).to eq(attributes[0][:species])
        end
      end
    end

  end

end
