require "rails_helper"

RSpec.describe 'LibrariesController', type: :request do

  let(:headers) do
    {
      'Content-Type' => 'application/vnd.api+json',
      'Accept' => 'application/vnd.api+json'
    }
  end

  context '#get' do
    let!(:libraries) { create_list(:library_with_tube, 5)}

    it 'returns a list of libraries' do
      get v1_libraries_path, headers: headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(5)
    end

    it 'returns the correct attributes' do
      get v1_libraries_path, headers: headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'][0]['attributes']['state']).to eq('pending')
      expect(json['data'][0]['relationships']['sample']['data']['id']).to eq(libraries[0].sample_id.to_s)
      expect(json['data'][0]['relationships']['tube']['data']['id']).to eq(libraries[0].tube_id.to_s)
    end
  end

  context 'when creating a single library' do
    context 'when the sample does exist' do
      let(:sample) { create(:sample) }
      let(:body) do
        {
          data: {
            attributes: {
              libraries: [
                { state: 'pending', sample_id: sample.id}
              ]
            }
          }
        }.to_json
      end

      it 'can returns created status' do
        post v1_libraries_path, params: body, headers: headers
        expect(response).to have_http_status(:created)
      end

      it 'can creates a library' do
        expect { post v1_libraries_path, params: body, headers: headers }.to change { Library.count }.by(1)
      end
    end

    context 'when the sample does not exist' do
      let(:body) do
        {
          data: {
            attributes: {
              libraries: [
                { state: 'pending', sample_id: 1}
              ]
            }
          }
        }.to_json
      end

      it 'can returns unprocessable entity status' do
        post v1_libraries_path, params: body, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'cannot create a library' do
        expect { post v1_libraries_path, params: body, headers: headers }.to change { Library.count }.by(0)
      end
    end

  end

  context 'when creating multiple libraries' do
    context 'when the sample does exist' do
      let(:sample) { create(:sample) }
      let(:body) do
        {
          data: {
            attributes: {
              libraries: [
                { state: 'pending', sample_id: sample.id},
                { state: 'pending', sample_id: sample.id},
                { state: 'pending', sample_id: sample.id}
              ]
            }
          }
        }.to_json
      end

      it 'can create libraries' do
        post v1_libraries_path, params: body, headers: headers
        expect(response).to have_http_status(:created)
      end
    end

    context 'when the sample does not exist' do
      let(:body) do
        {
          data: {
            attributes: {
              libraries: [
                { state: 'pending', sample_id: 1},
                { state: 'pending', sample_id: 1}
              ]
            }
          }
        }.to_json
      end

      it 'cannot create libraries' do
        post v1_libraries_path, params: body, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

  end

end
