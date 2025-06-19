# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AnnotationTypesController' do
  describe '#get' do
    let!(:annotation_type1) { create(:annotation_type) }
    let!(:annotation_type2) { create(:annotation_type) }

    it 'returns a list of active annotation types' do
      get v1_annotation_types_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get v1_annotation_types_path, headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['type']).to eq('annotation_types')
      expect(json['data'][0]['attributes']['name']).to eq(annotation_type1.name)
      expect(json['data'][1]['attributes']['name']).to eq(annotation_type2.name)
    end

    it 'returns a particular annotation type' do
      get v1_annotation_type_path(annotation_type1), headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data']['type']).to eq('annotation_types')
      expect(json['data']['attributes']['name']).to eq(annotation_type1.name)
    end

    it 'does not allow creation of annotation types via the API' do
      expect do
        post v1_annotation_types_path,
             params: {
               data: {
                 type: 'annotation_types',
                 attributes: { name: 'NewType' }
               }
             }.to_json,
             headers: json_api_headers
      end.to raise_error(ActionController::RoutingError)
    end
  end
end
