require "rails_helper"

RSpec.describe 'LibrariesController', type: :request do

  context '#get' do
    let!(:library1) { create(:library) }
    let!(:library2) { create(:library) }
    let!(:tube1) { create(:tube, material: library1)}
    let!(:tube2) { create(:tube, material: library2)}

    it 'returns a list of libraries' do
      get v1_libraries_path, headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get v1_libraries_path, headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['attributes']['state']).to eq(library1.state)
      expect(json['data'][0]['attributes']['barcode']).to eq(library1.tube.barcode)
      expect(json['data'][0]['attributes']['sample_name']).to eq(library1.sample.name)
      expect(json['data'][0]['attributes']['enzyme_name']).to eq(library1.enzyme.name)
      expect(json['data'][1]['attributes']['state']).to eq(library2.state)
      expect(json['data'][1]['attributes']['barcode']).to eq(library2.tube.barcode)
      expect(json['data'][1]['attributes']['enzyme_name']).to eq(library2.enzyme.name)
    end

    context 'when some libraries are deactivated' do
      let!(:library3) { create(:library) }
      let!(:library4) { create(:library, deactivated_at: DateTime.now) }
      let!(:tube3) { create(:tube, material: library3)}
      let!(:tube4) { create(:tube, material: library4)}

      it 'only returns active libraries' do
        get v1_libraries_path, headers: json_api_headers

        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'].length).to eq(3)
      end
    end
  end

  context '#create' do
    context 'when creating a single library' do

      context 'on success' do
        let(:sample) { create(:sample) }
        let(:enzyme) { create(:enzyme) }
        let(:body) do
          {
            data: {
              attributes: {
                libraries: [
                  { state: 'pending', sample_id: sample.id, enzyme_id: enzyme.id}
                ]
              }
            }
          }.to_json
        end

        it 'has a created status' do
          post v1_libraries_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created)
        end

        it 'creates a library' do
          expect { post v1_libraries_path, params: body, headers: json_api_headers }.to change { Library.count }.by(1)
        end

        it 'creates a library with a tube' do
          post v1_libraries_path, params: body, headers: json_api_headers
          expect(Library.last.tube).to be_present
          tube_id = Library.last.tube.id
          expect(Tube.find(tube_id).material).to eq Library.last
        end

        it 'creates a library with a sample' do
          post v1_libraries_path, params: body, headers: json_api_headers
          expect(Library.last.sample).to be_present
          sample_id = Library.last.sample.id
          expect(sample_id).to eq sample.id
        end

        it 'creates a library with a enzyme' do
          post v1_libraries_path, params: body, headers: json_api_headers
          expect(Library.last.enzyme).to be_present
          enzyme_id = Library.last.enzyme.id
          expect(enzyme_id).to eq enzyme.id
        end
      end

      context 'on failure' do
        context 'when the sample does not exist' do
          let(:enzyme) { create(:enzyme) }

          let(:body) do
            {
              data: {
                attributes: {
                  libraries: [
                    { state: 'pending', sample_id: 1, enzyme_id: enzyme.id}
                  ]
                }
              }
            }.to_json
          end

          it 'can returns unprocessable entity status' do
            post v1_libraries_path, params: body, headers: json_api_headers
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'cannot create a library' do
            expect { post v1_libraries_path, params: body, headers: json_api_headers }.to change { Library.count }.by(0)
          end
        end

        context 'when the enzyme does not exist' do
          let(:sample) { create(:sample) }

          let(:body) do
            {
              data: {
                attributes: {
                  libraries: [
                    { state: 'pending', sample_id: sample, enzyme_id: 1}
                  ]
                }
              }
            }.to_json
          end

          it 'can returns unprocessable entity status' do
            post v1_libraries_path, params: body, headers: json_api_headers
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'cannot create a library' do
            expect { post v1_libraries_path, params: body, headers: json_api_headers }.to change { Library.count }.by(0)
          end
        end

      end


    end

    context 'when creating multiple libraries' do
      context 'on success' do
        context 'when the sample does exist' do
          let(:sample) { create(:sample) }
          let(:enzyme) { create(:enzyme) }

          let(:body) do
            {
              data: {
                attributes: {
                  libraries: [
                    { state: 'pending', sample_id: sample.id, enzyme_id: enzyme.id},
                    { state: 'pending', sample_id: sample.id, enzyme_id: enzyme.id},
                    { state: 'pending', sample_id: sample.id, enzyme_id: enzyme.id}
                  ]
                }
              }
            }.to_json
          end

          it 'can create libraries' do
            post v1_libraries_path, params: body, headers: json_api_headers
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
                    { state: 'pending', sample_id: 1, enzyme_id: 1},
                    { state: 'pending', sample_id: 1, enzyme_id: 1}
                  ]
                }
              }
            }.to_json
          end

          it 'cannot create libraries' do
            post v1_libraries_path, params: body, headers: json_api_headers
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

    end
  end

  context '#destroy' do
    let!(:library) { create(:library) }
    let!(:tube) { create(:tube, material: library)}

    it 'deactivates the library' do
      delete "/v1/libraries/#{library.id}", headers: json_api_headers

      expect(response).to have_http_status(:no_content)
      library.reload
      expect(library.deactivated_at).to be_present
    end
  end

end
