require "rails_helper"

RSpec.describe 'LibrariesController', type: :request do

  context '#get' do
    let!(:library1) { create(:saphyr_library) }
    let!(:library2) { create(:saphyr_library) }
    let!(:tube1) { create(:tube, material: library1)}
    let!(:tube2) { create(:tube, material: library2)}

    it 'returns a list of libraries' do
      get v1_saphyr_libraries_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get v1_saphyr_libraries_path, headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['attributes']['state']).to eq(library1.state)
      expect(json['data'][0]['attributes']['barcode']).to eq(library1.tube.barcode)
      expect(json['data'][0]['attributes']['sample_name']).to eq(library1.request.sample_name)
      expect(json['data'][0]['attributes']['enzyme_name']).to eq(library1.enzyme.name)
      expect(json['data'][0]["attributes"]["created_at"]).to eq(library1.created_at.strftime("%m/%d/%Y %I:%M"))
      expect(json['data'][0]["attributes"]["deactivated_at"]).to eq(nil)

      expect(json['data'][1]['attributes']['state']).to eq(library2.state)
      expect(json['data'][1]['attributes']['barcode']).to eq(library2.tube.barcode)
      expect(json['data'][1]['attributes']['enzyme_name']).to eq(library2.enzyme.name)
      expect(json['data'][1]["attributes"]["created_at"]).to eq(library2.created_at.strftime("%m/%d/%Y %I:%M"))
      expect(json['data'][1]["attributes"]["deactivated_at"]).to eq(nil)
    end

    context 'when some libraries are deactivated' do
      let!(:library3) { create(:saphyr_library) }
      let!(:library4) { create(:saphyr_library, deactivated_at: DateTime.now) }
      let!(:tube3) { create(:tube, material: library3)}
      let!(:tube4) { create(:tube, material: library4)}

      it 'only returns active libraries' do
        get v1_saphyr_libraries_path, headers: json_api_headers

        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'].length).to eq(3)
      end
    end
  end

  context '#create' do
    context 'when creating a single library' do

      context 'on success' do
        let(:request) { create(:saphyr_request) }
        let(:saphyr_enzyme) { create(:saphyr_enzyme) }
        let(:body) do
          {
            data: {
              attributes: {
                libraries: [
                  { state: 'pending', saphyr_request_id: request.id, saphyr_enzyme_id: saphyr_enzyme.id}
                ]
              }
            }
          }.to_json
        end

        it 'has a created status' do
          post v1_saphyr_libraries_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created)
        end

        it 'creates a library' do
          expect { post v1_saphyr_libraries_path, params: body, headers: json_api_headers }.to change { Saphyr::Library.count }.by(1)
        end

        it 'creates a library with a tube' do
          post v1_saphyr_libraries_path, params: body, headers: json_api_headers
          expect(Saphyr::Library.last.tube).to be_present
          tube_id = Saphyr::Library.last.tube.id
          expect(Tube.find(tube_id).material).to eq Saphyr::Library.last
        end

        it 'creates a library with a request' do
          post v1_saphyr_libraries_path, params: body, headers: json_api_headers
          expect(Saphyr::Library.last.request).to be_present
          request_id = Saphyr::Library.last.request.id
          expect(request_id).to eq request.id
        end

        it 'creates a library with a enzyme' do
          post v1_saphyr_libraries_path, params: body, headers: json_api_headers
          expect(Saphyr::Library.last.enzyme).to be_present
          enzyme_id = Saphyr::Library.last.enzyme.id
          expect(enzyme_id).to eq saphyr_enzyme.id
        end
      end

      context 'on failure' do
        context 'when the request does not exist' do
          let(:saphyr_enzyme) { create(:saphyr_enzyme) }

          let(:body) do
            {
              data: {
                attributes: {
                  libraries: [
                    { state: 'pending', saphyr_request_id: 1, saphyr_enzyme_id: saphyr_enzyme.id}
                  ]
                }
              }
            }.to_json
          end

          it 'can returns unprocessable entity status' do
            post v1_saphyr_libraries_path, params: body, headers: json_api_headers
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'cannot create a library' do
            expect { post v1_saphyr_libraries_path, params: body, headers: json_api_headers }.to change { Saphyr::Library.count }.by(0)
          end

          it 'has an error message' do
            post v1_saphyr_libraries_path, params: body, headers: json_api_headers
            expect(JSON.parse(response.body)["data"]).to include("errors" => {"request"=>['must exist']})
          end
        end

        context 'when the enzyme does not exist' do
          let(:request) { create(:saphyr_request) }

          let(:body) do
            {
              data: {
                attributes: {
                  libraries: [
                    { state: 'pending', saphyr_request_id: request.id, enzyme_id: 1}
                  ]
                }
              }
            }.to_json
          end

          it 'can returns unprocessable entity status' do
            post v1_saphyr_libraries_path, params: body, headers: json_api_headers
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'cannot create a library' do
            expect { post v1_saphyr_libraries_path, params: body, headers: json_api_headers }.to change { Saphyr::Library.count }.by(0)
          end

          it 'has an error message' do
            post v1_saphyr_libraries_path, params: body, headers: json_api_headers
            expect(JSON.parse(response.body)["data"]).to include("errors" => {"enzyme"=>['must exist']})
          end
        end

      end


    end

    context 'when creating multiple libraries' do
      context 'on success' do
        context 'when the request does exist' do
          let(:request) { create(:saphyr_request) }
          let(:saphyr_enzyme) { create(:saphyr_enzyme) }

          let(:body) do
            {
              data: {
                attributes: {
                  libraries: [
                    { state: 'pending', saphyr_request_id: request.id, saphyr_enzyme_id: saphyr_enzyme.id},
                    { state: 'pending', saphyr_request_id: request.id, saphyr_enzyme_id: saphyr_enzyme.id},
                    { state: 'pending', saphyr_request_id: request.id, saphyr_enzyme_id: saphyr_enzyme.id}
                  ]
                }
              }
            }.to_json
          end

          it 'can create libraries' do
            post v1_saphyr_libraries_path, params: body, headers: json_api_headers
            expect(response).to have_http_status(:created)
          end
        end
      end

      context 'on failure' do
        context 'when the request does not exist' do
          let(:saphyr_enzyme) { create(:saphyr_enzyme) }

          let(:body) do
            {
              data: {
                attributes: {
                  libraries: [
                    { state: 'pending', saphyr_request_id: 1, saphyr_enzyme_id: saphyr_enzyme.id},
                    { state: 'pending', saphyr_request_id: 1, saphyr_enzyme_id: saphyr_enzyme.id}
                  ]
                }
              }
            }.to_json
          end

          it 'cannot create libraries' do
            post v1_saphyr_libraries_path, params: body, headers: json_api_headers
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'has an error message' do
            post v1_saphyr_libraries_path, params: body, headers: json_api_headers
            expect(JSON.parse(response.body)["data"]).to include("errors" => {"request"=>['must exist', 'must exist']})
          end
        end
      end

    end
  end

  context '#destroy' do
    context 'on success' do
      let!(:library) { create(:saphyr_library) }
      let!(:tube) { create(:tube, material: library)}

      it 'deactivates the library' do
        delete "/v1/saphyr/libraries/#{library.id}", headers: json_api_headers

        expect(response).to have_http_status(:no_content)
        library.reload
        expect(library.deactivated_at).to be_present
      end
    end

    context 'on failure' do
      let!(:library) { create(:saphyr_library) }

      before do
        library.deactivate
      end

      it 'does not deactivate the library' do
        delete "/v1/saphyr/libraries/#{library.id}", headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        delete "/v1/saphyr/libraries/#{library.id}", headers: json_api_headers
        expect(JSON.parse(response.body)["data"]).to include("errors" => {})
      end
    end
  end

end
