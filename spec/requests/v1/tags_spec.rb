require "rails_helper"

RSpec.describe 'TagsController', type: :request do

  context '#get' do
    let!(:tag1) { create(:tag) }
    let!(:tag2) { create(:tag) }

    it 'returns a list of tags' do
      get v1_tags_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get v1_tags_path, headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['attributes']['oligo']).to eq(tag1.oligo)
      expect(json['data'][1]['attributes']['oligo']).to eq(tag2.oligo)
    end

  end

  context '#create' do
    context 'on success' do

      let(:body) do
        {
          data: {
            type: 'tags',
            attributes: attributes_for(:tag)
          }
        }.to_json
      end

      it 'has a created status' do
        post v1_tags_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a tag' do
        expect { post v1_tags_path, params: body, headers: json_api_headers }.to change { Tag.count }.by(1)
      end

      it 'creates a tag with the correct attributes' do
        post v1_tags_path, params: body, headers: json_api_headers
        tag = Tag.first
        expect(tag.oligo).to be_present
      end
    end

    context 'on failure' do
      context 'when the necessary attributes are not provided' do      #
        let(:body) do
          {
            data: {
              type: 'tags',
              attributes: {}
            }
          }.to_json
        end

        it 'can returns unprocessable entity status' do
          post v1_tags_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'cannot create a tag' do
          expect { post v1_tags_path, params: body, headers: json_api_headers }.to_not change(Tag, :count)
        end

        it 'has an error message' do
          post v1_tags_path, params: body, headers: json_api_headers
          expect(JSON.parse(response.body)["data"]).to include("errors" => {"group_id"=>["can't be blank"], "oligo"=>["can't be blank"], "set_name"=>["can't be blank"]})
        end
      end
    end

  end

  context '#update' do
    let(:tag) { create(:tag) }

    context 'on success' do
      let(:body) do
        {
          data: {
            type: "tags",
            id: tag.id,
            attributes: {
              "oligo": "ACDC"
            }
          }
        }.to_json
      end

      it 'has a ok status' do
        patch v1_tag_path(tag), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates a tag' do
        patch v1_tag_path(tag), params: body, headers: json_api_headers
        tag.reload
        expect(tag.oligo).to eq "ACDC"
      end

      it 'returns the correct attributes' do
        patch v1_tag_path(tag), params: body, headers: json_api_headers
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['id']).to eq tag.id.to_s
      end
    end

    context 'on failure' do
      let(:body) do
        {
          data: {
            type: "tags",
            id: 123,
            attributes: {
              "oligo": "ACDC"
            }
          }
        }.to_json
      end

      it 'has a ok unprocessable_entity' do
        patch v1_tag_path(123), params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        patch v1_tag_path(123), params: body, headers: json_api_headers
        expect(JSON.parse(response.body)["data"]).to include("errors" => "Couldn't find Tag with 'id'=123")
      end
    end
  end

  context '#destroy' do
    context 'on success' do
      let!(:tag) { create(:tag) }

      it 'returns the correct status' do
        delete "/v1/tags/#{tag.id}", headers: json_api_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'destroys the tag' do
        expect { delete "/v1/tags/#{tag.id}", headers: json_api_headers }.to change { Tag.count }.by(-1)
      end

    end

    context 'on failure' do
      it 'returns the correct status' do
        delete "/v1/tags/123", headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        delete v1_tag_path(123), headers: json_api_headers
        data = JSON.parse(response.body)['data']
        expect(data['errors']).to be_present
      end
    end
  end
end
