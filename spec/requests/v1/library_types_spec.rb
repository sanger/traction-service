# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'LibraryTypesController' do
  describe '#get' do
    before { create(:library_type, active: false) }

    let!(:library_type1) { create(:library_type) }
    let!(:library_type2) { create(:library_type) }

    it 'returns a list of active library types' do
      get v1_library_types_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get v1_library_types_path, headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['attributes']['name']).to eq(library_type1.name)
      expect(json['data'][1]['attributes']['name']).to eq(library_type2.name)
    end
  end

  describe '#create' do
    context 'on success' do
      let(:attributes) { attributes_for(:library_type).transform_values(&:to_s) }

      let(:body) do
        {
          data: {
            type: 'library_types',
            attributes:
          }
        }.to_json
      end

      it 'has a created status' do
        post v1_library_types_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a library type' do
        expect do
          post v1_library_types_path, params: body, headers: json_api_headers
        end.to change(LibraryType, :count).by(1)
      end

      it 'creates a library type with the correct attributes' do
        post v1_library_types_path, params: body, headers: json_api_headers
        library_type = LibraryType.last
        expect(library_type).to have_attributes(attributes)
      end
    end

    context 'on failure' do
      context 'when the necessary attributes are not provided' do
        let(:attributes) { attributes_for(:library_type).transform_values(&:to_s).except(:pipeline) }
        let(:body) do
          {
            data: {
              type: 'library_types',
              attributes:
            }
          }.to_json
        end

        it 'can returns unprocessable entity status' do
          post v1_library_types_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'cannot create a library type' do
          expect do
            post v1_library_types_path, params: body, headers: json_api_headers
          end.not_to change(LibraryType, :count)
        end

        it 'has an error message' do
          post v1_library_types_path, params: body, headers: json_api_headers
          expect(JSON.parse(response.body)['errors'][0]).to include('detail' => "pipeline - can't be blank")
        end
      end
    end

    describe '#update' do
      let(:library_type) { create(:library_type) }

      context 'on success' do
        let(:body) do
          {
            data: {
              type: 'library_types',
              id: library_type.id,
              attributes: {
                name: 'Test library type update context'
              }
            }
          }.to_json
        end

        it 'has a ok status' do
          patch v1_library_type_path(library_type), params: body, headers: json_api_headers
          expect(response).to have_http_status(:ok)
        end

        it 'updates a library type' do
          patch v1_library_type_path(library_type), params: body, headers: json_api_headers
          library_type.reload
          expect(library_type.name).to eq 'Test library type update context'
        end

        it 'returns the correct attributes' do
          patch v1_library_type_path(library_type), params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          expect(json['data']['id']).to eq library_type.id.to_s
        end
      end

      context 'on failure' do
        let(:body) do
          {
            data: {
              type: 'library_types',
              id: 123,
              attributes: {
                name: 'Test library type update context'
              }
            }
          }.to_json
        end

        # the failure responses are slightly different to in tags_spec because we are using the default controller
        it 'has a ok unprocessable_entity' do
          patch v1_library_type_path(123), params: body, headers: json_api_headers
          expect(response).to have_http_status(:not_found)
        end

        # the failure responses are slightly different to in tags_spec because we are using the default controller
        it 'has an error message' do
          patch v1_library_type_path(123), params: body, headers: json_api_headers
          expect(JSON.parse(response.body)['errors'][0]).to include('detail' => 'The record identified by 123 could not be found.')
        end
      end
    end
  end
end
