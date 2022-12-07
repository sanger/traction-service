# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'LibrariesController', ont: true do
  before do
    Flipper.enable(:dpl_279_ont_libraries_and_pools)
  end

  describe '#get' do
    let!(:libraries) { create_list(:ont_library, 5, :tagged) }

    context 'without includes' do
      before do
        get v1_ont_libraries_path, headers: json_api_headers
      end

      it 'has a success status' do
        expect(response).to have_http_status(:success), response.body
      end

      it 'returns a list of libraries' do
        expect(json['data'].length).to eq(5)
      end

      it 'returns the correct attributes', aggregate_failures: true do
        libraries.each do |library|
          library_attributes = find_resource(type: 'libraries', id: library.id)['attributes']
          expect(library_attributes['volume']).to eq(library.volume)
          expect(library_attributes['concentration']).to eq(library.concentration)
          expect(library_attributes['kit_barcode']).to eq(library.kit_barcode)
          expect(library_attributes['insert_size']).to eq(library.insert_size)
          expect(library_attributes['state']).to eq(library.state)
          expect(library_attributes['created_at']).to eq(library.created_at.to_fs(:us))
          expect(library_attributes['deactivated_at']).to be_nil
        end
      end
    end

    context 'with includes' do
      before do
        get "#{v1_ont_libraries_path}?include=request,tag.tag_set,tube",
            headers: json_api_headers
      end

      let(:library_relationships) do
        library_resource = find_resource(type: 'libraries', id: libraries.first.id)
        library_resource.fetch('relationships')
      end
      let(:library) { libraries.first }

      it 'has a success status' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the correct relationships and included data', aggregate_failures: true do
        request = library.request
        request_relationship = library_relationships.dig('request', 'data')
        expect(request_relationship['id']).to eq(request.id.to_s)
        expect(request_relationship['type']).to eq('requests')

        request_resource = find_included_resource(type: 'requests', id: request.id)
        expect(request_resource.dig('attributes', 'library_type')).to eq(request.library_type.name)

        tag = library.tag
        tag_relationship = library_relationships['tag']
        expect(tag_relationship['data']['id']).to eq(tag.id.to_s)
        expect(tag_relationship['data']['type']).to eq('tags')

        tag_resource = find_included_resource(type: 'tags', id: tag.id)
        tag_attributes = tag_resource['attributes']
        expect(tag_attributes['oligo']).to eq(tag.oligo)
        expect(tag_attributes['group_id']).to eq(tag.group_id)

        tag_set = tag.tag_set
        tag_set_relationship = tag_resource['relationships']['tag_set']
        expect(tag_set_relationship['data']['id']).to eq(tag_set.id.to_s)
        expect(tag_set_relationship['data']['type']).to eq('tag_sets')

        tag_set_resource = find_included_resource(type: 'tag_sets', id: tag_set.id)
        tag_set_attributes = tag_set_resource['attributes']
        expect(tag_set_attributes['name']).to eq(tag_set.name)
        expect(tag_set_attributes['uuid']).to eq(tag_set.uuid)

        tube = library.tube
        tube_relationship = library_relationships.fetch('tube')
        expect(tube_relationship['data']['id']).to eq(tube.id.to_s)
        expect(tube_relationship['data']['type']).to eq('tubes')

        tube_resource = find_included_resource(type: 'tubes', id: tube.id)
        tube_attributes = tube_resource['attributes']
        expect(tube_attributes['barcode']).to eq(tube.barcode)

        pool = library.pool
        pool_relationship = library_relationships.fetch('pool')
        expect(pool_relationship['data']['id']).to eq(pool.id.to_s)
        expect(pool_relationship['data']['type']).to eq('pools')
      end

      it 'has a relationship with source_well' do
        expect(library_relationships['source_well']).to be_present
      end

      it 'has a relationship with source_plate' do
        expect(library_relationships['source_plate']).to be_present
      end
    end

    context 'pagination' do
      let!(:expected_libraries) { create_list(:ont_library, 5, :tagged) }

      before do
        # There should be 10 libraries total so we should get the 5 we just created
        get "#{v1_ont_libraries_path}?page[number]=2&page[size]=5",
            headers: json_api_headers
      end

      it 'has a success status' do
        expect(response).to have_http_status(:success), response.body
      end

      it 'returns a list of libraries' do
        expect(json['data'].length).to eq(5)
      end

      it 'returns the correct attributes', aggregate_failures: true do
        expected_libraries.each do |library|
          library_attributes = find_resource(type: 'libraries', id: library.id)['attributes']
          expect(library_attributes['volume']).to eq(library.volume)
          expect(library_attributes['concentration']).to eq(library.concentration)
          expect(library_attributes['kit_barcode']).to eq(library.kit_barcode)
          expect(library_attributes['insert_size']).to eq(library.insert_size)
          expect(library_attributes['state']).to eq(library.state)
          expect(library_attributes['created_at']).to eq(library.created_at.to_fs(:us))
          expect(library_attributes['deactivated_at']).to be_nil
        end
      end
    end
  end

  describe '#destroy' do
    context 'on success' do
      let!(:library) { create(:ont_library) }

      it 'returns the correct status' do
        delete "/v1/ont/libraries/#{library.id}", headers: json_api_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'destroys the library' do
        expect do
          delete "/v1/ont/libraries/#{library.id}", headers: json_api_headers
        end.to change(Ont::Library, :count).by(-1)
      end

      it 'does not destroy the requests' do
        expect do
          delete "/v1/ont/libraries/#{library.id}", headers: json_api_headers
        end.not_to change(Ont::Request, :count)
      end
    end

    context 'on failure' do
      it 'does not delete the library' do
        delete '/v1/ont/libraries/dodgyid', headers: json_api_headers
        expect(response).to have_http_status(:bad_request)
      end

      it 'has an error message' do
        delete '/v1/ont/libraries/dodgyid', headers: json_api_headers
        expect(json['errors']).to be_present
      end
    end
  end
end
