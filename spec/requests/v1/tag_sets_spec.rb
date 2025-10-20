# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TagSetsController' do
  describe '#get' do
    let!(:tag_set1) { create(:tag_set) }
    let!(:tag_set2) { create(:tag_set) }

    it 'returns a list of tag sets' do
      get v1_tag_sets_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get v1_tag_sets_path, headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['attributes']['name']).to eq(tag_set1.name)
      expect(json['data'][1]['attributes']['name']).to eq(tag_set2.name)
    end
  end

  describe '#create' do
    context 'on success' do
      let(:body) do
        {
          data: {
            type: 'tag_sets',
            attributes: attributes_for(:tag_set)
          }
        }.to_json
      end

      it 'has a created status' do
        post v1_tag_sets_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a tag set' do
        expect do
          post v1_tag_sets_path, params: body, headers: json_api_headers
        end.to change(TagSet, :count).by(1)
      end

      it 'creates a tag set with the correct attributes' do
        post v1_tag_sets_path, params: body, headers: json_api_headers
        tag_set = TagSet.first
        expect(tag_set.uuid).to be_present
      end
    end

    context 'on failure' do
      context 'when the necessary attributes are not provided' do
        let(:body) do
          {
            data: {
              type: 'tag_sets',
              attributes: {}
            }
          }.to_json
        end

        it 'can returns unprocessable entity status' do
          post v1_tag_sets_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'cannot create a tag set' do
          expect do
            post v1_tag_sets_path, params: body, headers: json_api_headers
          end.not_to change(TagSet, :count)
        end

        # the failure responses are slightly different to in tags_spec because we are using the default controller
        it 'has an error message' do
          post v1_tag_sets_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          expect(json['errors'][0]).to include('detail' => "name - can't be blank")
        end
      end
    end

    describe '#update' do
      let(:tag_set) { create(:tag_set) }

      context 'on success' do
        let(:body) do
          {
            data: {
              type: 'tag_sets',
              id: tag_set.id,
              attributes: {
                name: 'Test Tag Set update context'
              }
            }
          }.to_json
        end

        it 'has a ok status' do
          patch v1_tag_set_path(tag_set), params: body, headers: json_api_headers
          expect(response).to have_http_status(:ok)
        end

        it 'updates a tag set' do
          patch v1_tag_set_path(tag_set), params: body, headers: json_api_headers
          tag_set.reload
          expect(tag_set.name).to eq 'Test Tag Set update context'
        end

        it 'returns the correct attributes' do
          patch v1_tag_set_path(tag_set), params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          expect(json['data']['id']).to eq tag_set.id.to_s
        end
      end

      context 'on failure' do
        let(:body) do
          {
            data: {
              type: 'tag_sets',
              id: 123,
              attributes: {
                name: 'Test Tag Set update context'
              }
            }
          }.to_json
        end

        # the failure responses are slightly different to in tags_spec because we are using the default controller
        it 'has a ok unprocessable_content' do
          patch v1_tag_set_path(123), params: body, headers: json_api_headers
          expect(response).to have_http_status(:not_found)
        end

        # the failure responses are slightly different to in tags_spec because we are using the default controller
        it 'has an error message' do
          patch v1_tag_set_path(123), params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          expect(json['errors'][0]['detail']).to eq('The record identified by 123 could not be found.')
        end
      end
    end
  end

  describe '#destroy' do
    context 'on success' do
      let!(:tag_set) { create(:tag_set) }

      it 'returns the correct status' do
        delete "/v1/tag_sets/#{tag_set.id}", headers: json_api_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'destroys the tag' do
        expect do
          delete "/v1/tag_sets/#{tag_set.id}", headers: json_api_headers
        end.to change(TagSet, :count).by(-1)
      end
    end

    context 'on failure' do
      # the failure responses are slightly different to in tags_spec because we are using the default controller
      it 'returns the correct status' do
        delete '/v1/tag_sets/123', headers: json_api_headers
        expect(response).to have_http_status(:not_found)
      end

      # the failure responses are slightly different to in tags_spec because we are using the default controller
      it 'has an error message' do
        delete v1_tag_set_path(123), headers: json_api_headers
        response_parsed = response.parsed_body
        expect(response_parsed['errors']).to be_present
      end
    end
  end
end
