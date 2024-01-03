# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'LibrariesController', :pacbio do
  describe '#get' do
    let!(:libraries) { create_list(:pacbio_library, 5, :tagged, tube: Tube.new) }

    context 'without includes' do
      before do
        get v1_pacbio_libraries_path, headers: json_api_headers
      end

      it 'has a success status' do
        expect(response).to have_http_status(:success), response.body
      end

      it 'returns a list of libraries' do
        expect(json['data'].length).to eq(5)
      end

      it 'returns the correct attributes', :aggregate_failures do
        libraries.each do |library|
          library_attributes = find_resource(type: 'libraries', id: library.id)['attributes']
          expect(library_attributes['volume']).to eq(library.volume)
          expect(library_attributes['concentration']).to eq(library.concentration)
          expect(library_attributes['template_prep_kit_box_barcode']).to eq(library.template_prep_kit_box_barcode)
          expect(library_attributes['insert_size']).to eq(library.insert_size)
          expect(library_attributes['state']).to eq(library.state)
          expect(library_attributes['created_at']).to eq(library.created_at.to_fs(:us))
          expect(library_attributes['deactivated_at']).to be_nil
          expect(library_attributes['source_identifier']).to eq(library.source_identifier)
        end
      end

      it 'includes library run suitability' do
        get v1_pacbio_libraries_path, headers: json_api_headers
        library_resource = find_resource(id: libraries.first.id, type: 'libraries')
        expect(library_resource.dig('attributes', 'run_suitability')).to eq({
                                                                              'ready_for_run' => true,
                                                                              'errors' => []
                                                                            })
      end

      context 'when not suited for run creation' do
        let!(:libraries) { create_list(:pacbio_library, 1, :tagged, insert_size: nil, tube: Tube.new) }

        it 'includes invalid library run suitability' do
          get v1_pacbio_libraries_path, headers: json_api_headers
          library_resource = find_resource(id: libraries.first.id, type: 'libraries')
          run_suitability = library_resource.dig('attributes', 'run_suitability')
          expect(run_suitability).to eq({
                                          'ready_for_run' => false,
                                          'errors' => [
                                            # We use the standard json-api errors object. Status is excluded
                                            # as it makes little sense in this context
                                            {
                                              'code' => '100',
                                              'detail' => "insert_size - can't be blank",
                                              'source' => { 'pointer' => '/data/attributes/insert_size' },
                                              'title' => "can't be blank"
                                            }
                                          ]
                                        })
        end
      end
    end

    context 'with includes' do
      before do
        get "#{v1_pacbio_libraries_path}?include=request,tag.tag_set,tube",
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

      it 'returns the correct relationships and included data', :aggregate_failures do
        request = library.request
        request_relationship = library_relationships.dig('request', 'data')
        expect(request_relationship['id']).to eq(request.id.to_s)
        expect(request_relationship['type']).to eq('requests')

        request_resource = find_included_resource(type: 'requests', id: request.id)
        expect(request_resource.dig('attributes', 'sample_name')).to eq(request.sample_name)

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
      context 'default' do
        let!(:expected_libraries) { create_list(:pacbio_library, 5, created_at: Time.zone.now + 10) }

        before do
          # There should be 10 libraries total so we get the 5 we just created
          get "#{v1_pacbio_libraries_path}?page[number]=1&page[size]=5",
              headers: json_api_headers
        end

        it 'has a success status' do
          expect(response).to have_http_status(:success), response.body
        end

        it 'returns a list of libraries' do
          expect(json['data'].length).to eq(5)
        end

        it 'returns the correct attributes', :aggregate_failures do
          expected_libraries.each do |library|
            library_attributes = find_resource(type: 'libraries', id: library.id)['attributes']
            expect(library_attributes).to include(
              'concentration' => library.concentration,
              'volume' => library.volume,
              'template_prep_kit_box_barcode' => library.template_prep_kit_box_barcode,
              'insert_size' => library.insert_size,
              'state' => library.state,
              'created_at' => library.created_at.to_fs(:us)
            )
          end
        end
      end

      context 'filters - source_identifier' do
        it 'when the source_identifier belongs to a plate' do
          pacbio_plate = create(:plate_with_wells_and_requests, pipeline: 'pacbio')
          pacbio_requests = pacbio_plate.wells.flat_map(&:pacbio_requests)
          pacbio_library = create(:pacbio_library, request: pacbio_requests[0])
          get "#{v1_pacbio_libraries_path}?filter[source_identifier]=#{pacbio_plate.barcode}",
              headers: json_api_headers

          expect(response).to have_http_status(:success)
          expect(json['data'].length).to eq(1)
          library_attributes = find_resource(type: 'libraries', id: pacbio_library.id)['attributes']
          expect(library_attributes).to include(
            'concentration' => pacbio_library.concentration,
            'volume' => pacbio_library.volume,
            'template_prep_kit_box_barcode' => pacbio_library.template_prep_kit_box_barcode,
            'insert_size' => pacbio_library.insert_size,
            'state' => pacbio_library.state,
            'created_at' => pacbio_library.created_at.to_fs(:us)
          )
        end

        it 'when the source_identifier belongs to a plate:well' do
          pacbio_plate = create(:plate_with_wells_and_requests, pipeline: 'pacbio')
          pacbio_requests = pacbio_plate.wells.flat_map(&:pacbio_requests)
          pacbio_library = create(:pacbio_library, request: pacbio_requests[0])
          # Search by the request source identifier in the format plate:well
          get "#{v1_pacbio_libraries_path}?filter[source_identifier]=#{pacbio_requests[0].source_identifier}",
              headers: json_api_headers

          expect(response).to have_http_status(:success)
          expect(json['data'].length).to eq(1)
          library_attributes = find_resource(type: 'libraries', id: pacbio_library.id)['attributes']
          expect(library_attributes).to include(
            'concentration' => pacbio_library.concentration,
            'volume' => pacbio_library.volume,
            'template_prep_kit_box_barcode' => pacbio_library.template_prep_kit_box_barcode,
            'insert_size' => pacbio_library.insert_size,
            'state' => pacbio_library.state,
            'created_at' => pacbio_library.created_at.to_fs(:us)
          )
        end

        it 'when the source_identifier belongs to a tube' do
          pacbio_tube = create(:tube_with_pacbio_request)
          pacbio_library = create(:pacbio_library, request: pacbio_tube.pacbio_requests[0])
          get "#{v1_pacbio_libraries_path}?filter[source_identifier]=#{pacbio_tube.barcode}",
              headers: json_api_headers

          expect(response).to have_http_status(:success)
          expect(json['data'].length).to eq(1)
          library_attributes = find_resource(type: 'libraries', id: pacbio_library.id)['attributes']
          expect(library_attributes).to include(
            'concentration' => pacbio_library.concentration,
            'volume' => pacbio_library.volume,
            'template_prep_kit_box_barcode' => pacbio_library.template_prep_kit_box_barcode,
            'insert_size' => pacbio_library.insert_size,
            'state' => pacbio_library.state,
            'created_at' => pacbio_library.created_at.to_fs(:us)
          )
        end
      end

      context 'filters - barcode' do
        it 'returns the correct library' do
          # We need to use the library from the pool until the aliquot work is finished.
          pacbio_library = create(:pacbio_library)
          # Create extra libraries to prevent false positive
          create_list(:pacbio_library, 5)
          get "#{v1_pacbio_libraries_path}?filter[barcode]=#{pacbio_library.pool.tube.barcode}",
              headers: json_api_headers
          expect(response).to have_http_status(:success)
          expect(json['data'].length).to eq(1)
          library_attributes = find_resource(type: 'libraries', id: pacbio_library.id)['attributes']
          expect(library_attributes).to include(
            'concentration' => pacbio_library.concentration,
            'volume' => pacbio_library.volume,
            'template_prep_kit_box_barcode' => pacbio_library.template_prep_kit_box_barcode,
            'insert_size' => pacbio_library.insert_size,
            'state' => pacbio_library.state,
            'created_at' => pacbio_library.created_at.to_fs(:us)
          )
        end

        it 'returns the correct libraries from a wildcard search' do
          pacbio_libraries = []
          (1..5).each do |i|
            pacbio_tube = create(:tube_with_pacbio_request, barcode: "test-100#{i}")
            pacbio_pool = create(:pacbio_pool, library_count: 1, tube: pacbio_tube)
            pacbio_libraries << pacbio_pool.libraries.first
          end
          # Create extra libraries to prevent false positive
          create_list(:pacbio_library, 5)
          get "#{v1_pacbio_libraries_path}?filter[barcode]=test-100,wildcard",
              headers: json_api_headers

          expect(response).to have_http_status(:success)
          expect(json['data'].length).to eq(5)
          pacbio_libraries.each do |library|
            library_attributes = find_resource(type: 'libraries', id: library.id)['attributes']
            expect(library_attributes).to include(
              'concentration' => library.concentration,
              'volume' => library.volume,
              'template_prep_kit_box_barcode' => library.template_prep_kit_box_barcode,
              'insert_size' => library.insert_size,
              'state' => library.state,
              'created_at' => library.created_at.to_fs(:us)
            )
          end
        end
      end
    end
  end

  describe '#destroy' do
    context 'on success' do
      let!(:library) { create(:pacbio_library) }

      it 'returns the correct status' do
        delete "/v1/pacbio/libraries/#{library.id}", headers: json_api_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'destroys the library' do
        expect do
          delete "/v1/pacbio/libraries/#{library.id}", headers: json_api_headers
        end.to change(Pacbio::Library, :count).by(-1)
      end

      it 'does not destroy the requests' do
        expect do
          delete "/v1/pacbio/libraries/#{library.id}", headers: json_api_headers
        end.not_to change(Pacbio::Request, :count)
      end
    end

    context 'on failure' do
      it 'does not delete the library' do
        delete '/v1/pacbio/libraries/dodgyid', headers: json_api_headers
        expect(response).to have_http_status(:bad_request)
      end

      it 'has an error message' do
        delete '/v1/pacbio/libraries/dodgyid', headers: json_api_headers
        expect(json['errors']).to be_present
      end
    end
  end
end
