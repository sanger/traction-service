require "rails_helper"

RSpec.describe 'LibrariesController', type: :request do

  let(:headers) do
    {
      'Content-Type' => 'application/vnd.api+json',
      'Accept' => 'application/vnd.api+json'
    }
  end

  context '#get' do
    let!(:library1) { create(:library) }
    let!(:library2) { create(:library) }
    let!(:tube1) { create(:tube, material: library1)}
    let!(:tube2) { create(:tube, material: library2)}

    it 'returns a list of libraries' do
      get v1_libraries_path, headers: headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get v1_libraries_path, headers: headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['attributes']['state']).to eq(library1.state)
      expect(json['data'][0]['attributes']['barcode']).to eq(library1.tube.barcode)
      expect(json['data'][0]['attributes']['sample-name']).to eq(library1.sample.name)
      expect(json['data'][1]['attributes']['state']).to eq(library2.state)
      expect(json['data'][1]['attributes']['barcode']).to eq(library2.tube.barcode)
      expect(json['data'][1]['attributes']['sample-name']).to eq(library2.sample.name)
    end
  end

  context 'when creating a single library' do

    context 'on success' do
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

      it 'has a created status' do
        post v1_libraries_path, params: body, headers: headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a library' do
        expect { post v1_libraries_path, params: body, headers: headers }.to change { Library.count }.by(1)
      end

      it 'creates a library with a tube' do
        post v1_libraries_path, params: body, headers: headers
        expect(Library.last.tube).to be_present
        tube_id = Library.last.tube.id
        expect(Tube.find(tube_id).material).to eq Library.last
      end

      it 'creates a library with a sample' do
        post v1_libraries_path, params: body, headers: headers
        expect(Library.last.sample).to be_present
        sample_id = Library.last.sample.id
        expect(sample_id).to eq sample.id
      end
    end

    context 'on failure' do
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


  end

  context 'when creating multiple libraries' do
    context 'on success' do
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
    end

    context 'on failure' do
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

end
