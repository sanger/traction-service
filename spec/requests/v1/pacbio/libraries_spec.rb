require "rails_helper"

RSpec.describe 'LibrariesController', type: :request, pacbio: true do

  let!(:request) { create(:pacbio_request) }
  let!(:tag) { create(:tag) }
  let!(:request2) { create(:pacbio_request) }
  let!(:tag2) { create(:tag) }

  context '#get' do
    let!(:libraries) { create_list(:pacbio_library_in_tube, 5, :tagged)}

    it 'returns a list of libraries' do
      get v1_pacbio_libraries_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(5)
    end

    it 'returns the correct attributes', aggregate_failures: true do
      get "#{v1_pacbio_libraries_path}", headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      library = libraries.first
      library_attributes = json['data'][0]['attributes']
      expect(library_attributes['volume']).to eq(library.volume)
      expect(library_attributes['concentration']).to eq(library.concentration)
      expect(library_attributes['template_prep_kit_box_barcode']).to eq(library.template_prep_kit_box_barcode)
      expect(library_attributes['fragment_size']).to eq(library.fragment_size)
      expect(library_attributes['state']).to eq(library.state)

      expect(library_attributes["created_at"]).to eq(library.created_at.to_s(:us))
      expect(library_attributes["deactivated_at"]).to eq(nil)
      expect(library_attributes['source_identifier']).to eq(library.source_identifier)

    end

    it 'returns the correct relationships and included data', aggregate_failures: true do
      get "#{v1_pacbio_libraries_path}?include=request,tag.tag_set,tube", headers: json_api_headers

      expect(response).to have_http_status(:success), response.body
      json = ActiveSupport::JSON.decode(response.body)

      request = libraries.first.request
      request_relationship = json['data'][0]['relationships']['request']
      expect(request_relationship['data']['id'].to_s).to eq(request.id.to_s)
      expect(request_relationship['data']['type'].to_s).to eq('requests')

      request_attributes = json['included'][0]['attributes']
      expect(request_attributes['sample_name']).to eq(request.sample_name)

      tag = libraries.first.tag
      tag_relationship = json['data'][0]['relationships']['tag']
      expect(tag_relationship['data']['id'].to_s).to eq(tag.id.to_s)
      expect(tag_relationship['data']['type'].to_s).to eq('tags')

      tag_attributes = json['included'][5]['attributes']
      expect(tag_attributes['oligo'].to_s).to eq(tag.oligo)
      expect(tag_attributes['group_id'].to_s).to eq(tag.group_id)

      tag_set = tag.tag_set
      tag_set_relationship = json['included'][5]['relationships']['tag_set']
      expect(tag_set_relationship['data']['id'].to_s).to eq(tag_set.id.to_s)
      expect(tag_set_relationship['data']['type'].to_s).to eq('tag_sets')

      tag_set_attributes = json['included'][10]['attributes']
      expect(tag_set_attributes['name']).to eq(tag_set.name)
      expect(tag_set_attributes['uuid']).to eq(tag_set.uuid)

      tube = libraries.first.tube
      tube_relationship = json['data'][0]['relationships']['tube']
      expect(tube_relationship['data']['id'].to_s).to eq(tube.id.to_s)
      expect(tube_relationship['data']['type'].to_s).to eq('tubes')

      tube_attributes = json['included'][15]['attributes']
      expect(tube_attributes['barcode']).to eq(tube.barcode)
    end

  end

  context '#create' do
    context 'when creating a singleplex library' do
      context 'on success' do
        let(:body) do
          {
            data: {
              type: 'libraries',
              attributes: {
                volume: 1.11,
                concentration: 2.22,
                template_prep_kit_box_barcode: 'LK1234567',
                fragment_size: 100
              },
              relationships: {
                request: { data: { type: 'requests', id: request.id } },
                tag: { data: { type: 'tags', id: tag.id } }
              }
            }
          }.to_json
        end

        it 'has a created status' do
          post v1_pacbio_libraries_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created)
        end

        it 'creates a library' do
          expect { post v1_pacbio_libraries_path, params: body, headers: json_api_headers }.to change { Pacbio::Library.count }.by(1)
        end

        it 'doe not create a request' do
          expect { post v1_pacbio_libraries_path, params: body, headers: json_api_headers }.not_to change { Pacbio::Request.count }
        end

        it 'associates the request, library request and tag' do
          post v1_pacbio_libraries_path, params: body, headers: json_api_headers
          library = Pacbio::Library.first
          expect(library.request).to eq(request)
          expect(library.tag).to eq(tag)
        end
      end

      context 'on failure' do
        context 'when library is invalid' do
          let(:body) do
            {
              data: {
                type: 'libraries',
                attributes: {
                  concentration: 2.22,
                  template_prep_kit_box_barcode: 'LK1234567',
                  fragment_size: 100
                },
                relationships: {
                  request: { data: { type: 'requests', id: request.id } },
                  tag: { data: { type: 'tags', id: tag.id } }
                }
              }
            }.to_json
          end

          it 'returns unprocessable entity status' do
            post v1_pacbio_libraries_path, params: body, headers: json_api_headers
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'cannot create a library' do
            expect { post v1_pacbio_libraries_path, params: body, headers: json_api_headers }.to_not change(Pacbio::Library, :count)
          end

          it 'cannot create a request' do
            expect { post v1_pacbio_libraries_path, params: body, headers: json_api_headers }.to_not change(Pacbio::Request, :count)
          end

          it 'has an error message' do
            post v1_pacbio_libraries_path, params: body, headers: json_api_headers
            expect(JSON.parse(response.body)["data"]).to include("errors" => {"volume"=>["can't be blank"]})
          end
        end

        context 'when the request is invalid' do
          let(:request_empty_cost_code) { create(:pacbio_request, cost_code: "")}

          let(:body) do
            {
              data: {
                type: 'libraries',
                attributes: {
                  volume: 1.11,
                  concentration: 2.22,
                  template_prep_kit_box_barcode: 'LK1234567',
                  fragment_size: 100
                },
                relationships: {
                  request: { data: { type: 'requests', id: request_empty_cost_code.id } },
                  tag: { data: { type: 'tags', id: tag.id } }
                }
              }
            }.to_json
          end

          it 'returns unprocessable entity status' do
            post v1_pacbio_libraries_path, params: body, headers: json_api_headers
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'cannot create a library' do
            expect { post v1_pacbio_libraries_path, params: body, headers: json_api_headers }.to_not change(Pacbio::Library, :count)
          end

          it 'cannot create a request' do
            cache_body = body
            expect { post v1_pacbio_libraries_path, params: cache_body, headers: json_api_headers }.to_not change(Pacbio::Request, :count)
          end

          it 'has an error message' do
            post v1_pacbio_libraries_path, params: body, headers: json_api_headers
            expect(JSON.parse(response.body)["data"]).to include("errors" => {"cost_code"=>["must be present"]})
          end

        end
      end
    end
  end

  context '#destroy' do
    context 'on success' do
      let!(:library) { create(:pacbio_library) }
      let!(:request) { library.request }

      it 'returns the correct status' do
        delete "/v1/pacbio/libraries/#{library.id}", headers: json_api_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'destroys the library' do
        expect { delete "/v1/pacbio/libraries/#{library.id}", headers: json_api_headers }.to change { Pacbio::Library.count }.by(-1)
      end

      it 'does not destroy the requests' do
        expect { delete "/v1/pacbio/libraries/#{library.id}", headers: json_api_headers }.not_to change { Pacbio::Request.count }
      end

    end

    context 'on failure' do
      it 'does not delete the library' do
        delete "/v1/pacbio/libraries/dodgyid", headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        delete "/v1/pacbio/libraries/dodgyid", headers: json_api_headers
        data = JSON.parse(response.body)['data']
        expect(data['errors']).to be_present
      end
    end
  end

end
