# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DataTypesController' do
  describe '#get' do
    let!(:data_type1) { create(:data_type) }
    let!(:data_type2) { create(:data_type) }

    it 'returns a list of data types' do
      get v1_data_types_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get v1_data_types_path, headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['attributes']['name']).to eq(data_type1.name)
      expect(json['data'][1]['attributes']['name']).to eq(data_type2.name)
    end
  end

  describe '#create' do
    context 'on success' do
      let(:attributes) { attributes_for(:data_type).transform_values(&:to_s) }

      let(:body) do
        {
          data: {
            type: 'data_types',
            attributes:
          }
        }.to_json
      end

      it 'has a created status' do
        post v1_data_types_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a data type' do
        expect do
          post v1_data_types_path, params: body, headers: json_api_headers
        end.to change(DataType, :count).by(1)
      end

      it 'creates a data type with the correct attributes' do
        post v1_data_types_path, params: body, headers: json_api_headers
        data_type = DataType.last
        expect(data_type).to have_attributes(attributes)
      end
    end

    context 'on failure' do
      context 'when the necessary attributes are not provided' do
        let(:attributes) { attributes_for(:data_type).transform_values(&:to_s).except(:pipeline) }
        let(:body) do
          {
            data: {
              type: 'data_types',
              attributes:
            }
          }.to_json
        end

        it 'can returns unprocessable entity status' do
          post v1_data_types_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'cannot create a data type' do
          expect do
            post v1_data_types_path, params: body, headers: json_api_headers
          end.not_to change(DataType, :count)
        end

        it 'has an error message' do
          post v1_data_types_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          expect(json['errors'][0]).to include('detail' => "pipeline - can't be blank")
        end
      end
    end

    describe '#update' do
      let(:data_type) { create(:data_type) }

      context 'on success' do
        let(:body) do
          {
            data: {
              type: 'data_types',
              id: data_type.id,
              attributes: {
                name: 'Test data type update context'
              }
            }
          }.to_json
        end

        it 'has a ok status' do
          patch v1_data_type_path(data_type), params: body, headers: json_api_headers
          expect(response).to have_http_status(:ok)
        end

        it 'updates a data type' do
          patch v1_data_type_path(data_type), params: body, headers: json_api_headers
          data_type.reload
          expect(data_type.name).to eq 'Test data type update context'
        end

        it 'returns the correct attributes' do
          patch v1_data_type_path(data_type), params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          expect(json['data']['id']).to eq data_type.id.to_s
        end
      end

      context 'on failure' do
        let(:body) do
          {
            data: {
              type: 'data_types',
              id: 123,
              attributes: {
                name: 'Test data type update context'
              }
            }
          }.to_json
        end

        # the failure responses are slightly different to in tags_spec because we are using the default controller
        it 'has a ok unprocessable_content' do
          patch v1_data_type_path(123), params: body, headers: json_api_headers
          expect(response).to have_http_status(:not_found)
        end

        # the failure responses are slightly different to in tags_spec because we are using the default controller
        it 'has an error message' do
          patch v1_data_type_path(123), params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          expect(json['errors'][0]).to include('detail' => 'The record identified by 123 could not be found.')
        end
      end
    end
  end
end
