# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'LibrariesController' do
  describe '#get' do
    let!(:library1) { create(:saphyr_library_in_tube) }
    let!(:library2) { create(:saphyr_library_in_tube) }

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
      expect(json['data'][0]['attributes']['created_at']).to eq(library1.created_at.to_fs(:us))
      expect(json['data'][0]['attributes']['deactivated_at']).to be_nil

      expect(json['data'][1]['attributes']['state']).to eq(library2.state)
      expect(json['data'][1]['attributes']['barcode']).to eq(library2.tube.barcode)
      expect(json['data'][1]['attributes']['enzyme_name']).to eq(library2.enzyme.name)
      expect(json['data'][1]['attributes']['created_at']).to eq(library2.created_at.to_fs(:us))
      expect(json['data'][1]['attributes']['deactivated_at']).to be_nil
    end

    context 'when some libraries are deactivated' do
      it 'only returns active libraries' do
        create(:saphyr_library_in_tube)
        create(:saphyr_library_in_tube, deactivated_at: DateTime.now)

        get v1_saphyr_libraries_path, headers: json_api_headers

        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'].length).to eq(3)
      end
    end
  end

  describe '#create' do
    context 'when creating a single library' do
      context 'on success' do
        let(:request) { create(:saphyr_request) }
        let(:saphyr_enzyme) { create(:saphyr_enzyme) }
        let(:body) do
          {
            data: {
              attributes: {
                libraries: [
                  { state: 'pending', saphyr_request_id: request.id,
                    saphyr_enzyme_id: saphyr_enzyme.id }
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
          expect do
            post v1_saphyr_libraries_path, params: body, headers: json_api_headers
          end.to change(Saphyr::Library, :count).by(1)
        end

        it 'creates a library with a tube' do
          post v1_saphyr_libraries_path, params: body, headers: json_api_headers
          expect(Saphyr::Library.last.tube).to be_present
          tube_id = Saphyr::Library.last.tube.id
          expect(Tube.find(tube_id).materials.first).to eq Saphyr::Library.last
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

      context 'on failure - when the request does not exist' do
        let(:saphyr_enzyme) { create(:saphyr_enzyme) }

        let(:body) do
          {
            data: {
              attributes: {
                libraries: [
                  { state: 'pending', saphyr_request_id: 1, saphyr_enzyme_id: saphyr_enzyme.id }
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
          expect do
            post v1_saphyr_libraries_path, params: body, headers: json_api_headers
          end.not_to change(Saphyr::Library, :count)
        end

        it 'has an error message' do
          post v1_saphyr_libraries_path, params: body, headers: json_api_headers
          expect(response.parsed_body['data']).to include('errors' => { 'request' => ['must exist'] })
        end
      end

      context 'on failure - when the enzyme does not exist' do
        let(:saphyr_enzyme) { create(:saphyr_enzyme) }
        let(:request) { create(:saphyr_request) }

        let(:body) do
          {
            data: {
              attributes: {
                libraries: [
                  { state: 'pending', saphyr_request_id: request.id, enzyme_id: 1 }
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
          expect do
            post v1_saphyr_libraries_path, params: body, headers: json_api_headers
          end.not_to change(Saphyr::Library, :count)
        end

        it 'has an error message' do
          post v1_saphyr_libraries_path, params: body, headers: json_api_headers
          expect(response.parsed_body['data']).to include('errors' => { 'enzyme' => ['must exist'] })
        end
      end
    end

    context 'when creating multiple libraries' do
      context 'on success - when the request does exist' do
        let(:request) { create(:saphyr_request) }
        let(:saphyr_enzyme) { create(:saphyr_enzyme) }

        let(:body) do
          {
            data: {
              attributes: {
                libraries: [
                  { state: 'pending', saphyr_request_id: request.id,
                    saphyr_enzyme_id: saphyr_enzyme.id },
                  { state: 'pending', saphyr_request_id: request.id,
                    saphyr_enzyme_id: saphyr_enzyme.id },
                  { state: 'pending', saphyr_request_id: request.id,
                    saphyr_enzyme_id: saphyr_enzyme.id }
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

      context 'on failure - when the request does not exist' do
        let(:saphyr_enzyme) { create(:saphyr_enzyme) }

        let(:body) do
          {
            data: {
              attributes: {
                libraries: [
                  { state: 'pending', saphyr_request_id: 1, saphyr_enzyme_id: saphyr_enzyme.id },
                  { state: 'pending', saphyr_request_id: 1, saphyr_enzyme_id: saphyr_enzyme.id }
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
          expect(response.parsed_body['data']).to include('errors' => { 'request' => [
            'must exist', 'must exist'
          ] })
        end
      end
    end
  end

  describe '#destroy' do
    context 'on success' do
      let!(:library) { create(:saphyr_library_in_tube) }

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
        expect(response.parsed_body['data']).to include('errors' => {})
      end
    end
  end
end
