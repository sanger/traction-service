require "rails_helper"

RSpec.describe 'LibrariesController', type: :request, pacbio: true do

  let!(:request) { create(:pacbio_request) }
  let!(:tag) { create(:tag) }
  let!(:request2) { create(:pacbio_request) }
  let!(:tag2) { create(:tag) }

  context '#get' do
    let!(:library1)         { create(:pacbio_library) }
    let!(:request_library1)  { create(:pacbio_request_library, library: library1, request: request, tag: tag)}
    let!(:library2)         { create(:pacbio_library) }
    let!(:request_library2)  { create(:pacbio_request_library, library: library2, request: request, tag: tag)}
    let!(:tube1) { create(:tube, material: library1)}
    let!(:tube2) { create(:tube, material: library2)}

    it 'returns a list of libraries' do
      get v1_pacbio_libraries_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get "#{v1_pacbio_libraries_path}?include=requests", headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['attributes']['volume']).to eq(library1.volume)
      expect(json['data'][0]['attributes']['concentration']).to eq(library1.concentration)
      expect(json['data'][0]['attributes']['library_kit_barcode']).to eq(library1.library_kit_barcode)
      expect(json['data'][0]['attributes']['fragment_size']).to eq(library1.fragment_size)
      expect(json['data'][0]['attributes']['sample_names']).to eq(library1.sample_names)
      expect(json['data'][0]['attributes']['state']).to eq(library1.state)
      expect(json['data'][0]['attributes']['barcode']).to eq(library1.tube.barcode)
      expect(json['data'][0]["attributes"]["created_at"]).to eq(library1.created_at.to_s(:us))
      expect(json['data'][0]["attributes"]["deactivated_at"]).to eq(nil)

      expect(json['data'][1]['attributes']['volume']).to eq(library2.volume)
      expect(json['data'][1]['attributes']['concentration']).to eq(library2.concentration)
      expect(json['data'][1]['attributes']['library_kit_barcode']).to eq(library2.library_kit_barcode)
      expect(json['data'][1]['attributes']['fragment_size']).to eq(library2.fragment_size)
      expect(json['data'][1]['attributes']['sample_names']).to eq(library2.sample_names)
      expect(json['data'][1]['attributes']['state']).to eq(library2.state)
      expect(json['data'][1]['attributes']['barcode']).to eq(library2.tube.barcode)
      expect(json['data'][1]["attributes"]["created_at"]).to eq(library2.created_at.to_s(:us))
      expect(json['data'][1]["attributes"]["deactivated_at"]).to eq(nil)
    end

    it 'returns the correct relationships and included data' do
      get "#{v1_pacbio_libraries_path}?include=requests", headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      library1Requests = json['data'][0]['relationships']['requests']
      expect(library1Requests['data'].length).to eq(1)
      expect(library1Requests['data'][0]['id'].to_s).to eq(request_library1.id.to_s)
      expect(library1Requests['data'][0]['type'].to_s).to eq('request_libraries')

      library2Requests = json['data'][1]['relationships']['requests']
      expect(library2Requests['data'].length).to eq(1)
      expect(library2Requests['data'][0]['id'].to_s).to eq(request_library2.id.to_s)
      expect(library2Requests['data'][0]['type'].to_s).to eq('request_libraries')

      request1 = json['included'][0]['attributes']
      expect(request1['sample_name']).to eq(request_library1.sample_name)
      expect(request1['tag_id'].to_s).to eq(request_library1.tag_id.to_s)
      expect(request1['tag_set_name']).to eq(request_library1.tag.tag_set.name)
      expect(request1['tag_group_id']).to eq(request_library1.tag_group_id)
      expect(request1['tag_oligo'].to_s).to eq(request_library1.tag_oligo)

      request2 = json['included'][1]['attributes']
      expect(request2['sample_name']).to eq(request_library2.sample_name)
      expect(request2['tag_id'].to_s).to eq(request_library2.tag_id.to_s)
      expect(request2['tag_set_name']).to eq(request_library2.tag.tag_set.name)
      expect(request2['tag_group_id']).to eq(request_library2.tag_group_id)
      expect(request2['tag_oligo'].to_s).to eq(request_library2.tag_oligo)
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
                libraries: [
                   { 
                      volume: 1.11,
                      concentration: 2.22,
                      library_kit_barcode: 'LK1234567',
                      fragment_size: 100,
                      relationships: {
                        requests: {
                          data: [
                            { 
                              type: 'requests', 
                              id: request.id, 
                              relationships: {
                                tag: {
                                  data: {
                                    type: 'tags',
                                    id: tag.id
                                  }
                                }
                              }
                            }
                          ]
                        }
                      }
                  }
                ]
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

        it 'creates a relationship between the request and tag' do
          post v1_pacbio_libraries_path, params: body, headers: json_api_headers
          request_library = Pacbio::RequestLibrary.first
          expect(request_library.library).to eq(Pacbio::Library.first) 
          expect(request_library.request).to eq(request) 
          expect(request_library.tag).to eq(tag) 
        end

      end

      context 'on failure when library is missing an attribute' do
        let(:body) do
          {
            data: {
              type: 'libraries',
              attributes: {
                libraries: [
                   { 
                      concentration: 2.22,
                      library_kit_barcode: 'LK1234567',
                      fragment_size: 100,
                      relationships: {
                        requests: {
                          data: [
                            { 
                              type: 'requests', 
                              id: request.id, 
                              relationships: {
                                tag: {
                                  data: {
                                    type: 'tags',
                                    id: tag.id
                                  }
                                }
                              }
                            }
                          ]
                        }
                      }
                  }
                ]
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

        it 'has an error message' do
          post v1_pacbio_libraries_path, params: body, headers: json_api_headers
          expect(JSON.parse(response.body)["data"]).to include("errors" => {"volume"=>["can't be blank"]})
        end

      end
    end
  
    context 'when creating a multiplex library' do
      context 'on success' do

        let(:body) do
        {
          data: {
            type: 'libraries',
            attributes: {
              libraries: [
                { 
                    volume: 1.11,
                    concentration: 2.22,
                    library_kit_barcode: 'LK1234567',
                    fragment_size: 100,
                    relationships: {
                      requests: {
                        data: [
                          { 
                            type: 'requests', 
                            id: request.id, 
                            relationships: {
                              tag: {
                                data: {
                                  type: 'tags',
                                  id: tag.id
                                }
                              }
                            }
                          },
                          { 
                            type: 'requests', 
                            id: request2.id, 
                            relationships: {
                              tag: {
                                data: {
                                  type: 'tags',
                                  id: tag2.id
                                }
                              }
                            }
                          }
                        ]
                      }
                    }
                }
              ]
            }
          }
        }.to_json
        end

        it 'can create libraries' do
          post v1_pacbio_libraries_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created)
          expect(Pacbio::Library.count).to eq(1)
          expect(Pacbio::Library.first.requests.count).to eq(2)
        end
      end

      context 'on failure when two different library requests have the same tag' do
         let(:body) do
          {
            data: {
              type: 'libraries',
              attributes: {
                libraries: [
                  { 
                      volume: 1.11,
                      concentration: 2.22,
                      library_kit_barcode: 'LK1234567',
                      fragment_size: 100,
                      relationships: {
                        requests: {
                          data: [
                            { 
                              type: 'requests', 
                              id: request.id, 
                              relationships: {
                                tag: {
                                  data: {
                                    type: 'tags',
                                    id: tag.id
                                  }
                                }
                              }
                            },
                            { 
                              type: 'requests', 
                              id: request2.id, 
                              relationships: {
                                tag: {
                                  data: {
                                    type: 'tags',
                                    id: tag.id
                                  }
                                }
                              }
                            }
                          ]
                        }
                      }
                  }
                ]
              }
            }
          }.to_json
        end

        it 'cannot create libraries' do
          post v1_pacbio_libraries_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'has an error message' do
          post v1_pacbio_libraries_path, params: body, headers: json_api_headers
          expect(JSON.parse(response.body)["data"]).to include("errors" => {"tag"=>["is used more than once"]})
        end
      end
    end

  end

  context '#destroy' do
    context 'on success' do
      let!(:library) { create(:pacbio_library) }

      it 'returns the correct status' do
        delete "/v1/pacbio/libraries/#{library.id}", headers: json_api_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'destroys the library' do
        expect { delete "/v1/pacbio/libraries/#{library.id}", headers: json_api_headers }.to change { Pacbio::Library.count }.by(-1)
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
