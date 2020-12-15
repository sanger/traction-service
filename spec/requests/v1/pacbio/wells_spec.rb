require "rails_helper"

RSpec.describe 'WellsController', type: :request do

  context '#get' do
    let!(:library1) { create(:pacbio_library_in_tube) }
    let!(:library2) { create(:pacbio_library_in_tube) }

    let!(:well1) { create(:pacbio_well, pre_extension_time: 2) }
    let!(:well2) { create(:pacbio_well, libraries: [library1, library2]) }

    it 'returns a list of wells' do
      get v1_pacbio_wells_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get "#{v1_pacbio_wells_path}?include=libraries", headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      puts v1_pacbio_wells_path
      puts json['data'][0]['attributes']
      expect(json['data'][0]['attributes']['pacbio_plate_id']).to eq(well1.pacbio_plate_id)
      expect(json['data'][0]['attributes']['row']).to eq(well1.row)
      expect(json['data'][0]['attributes']['column']).to eq(well1.column)
      # TODO: fix movie time column
      expect(json['data'][0]['attributes']['movie_time'].to_s).to eq(well1.movie_time.to_s)
      expect(json['data'][0]['attributes']['insert_size']).to eq(well1.insert_size)
      expect(json['data'][0]['attributes']['on_plate_loading_concentration']).to eq(well1.on_plate_loading_concentration)
      expect(json['data'][0]['attributes']['pacbio_plate_id']).to eq(well1.pacbio_plate_id)
      expect(json['data'][0]['attributes']['comment']).to eq(well1.comment)
      expect(json['data'][0]['attributes']['sequencing_mode']).to eq(well1.sequencing_mode)
      expect(json['data'][0]['attributes']['pre_extension_time']).to eq(well1.pre_extension_time)
      expect(json['data'][0]['attributes']['generate_hifi']).to eq(well1.generate_hifi)

      well = json['data'][1]['attributes']
      expect(well['pacbio_plate_id']).to eq(well2.pacbio_plate_id)
      expect(well['row']).to eq(well2.row)
      expect(well['column']).to eq(well2.column)
      expect(well['movie_time'].to_s).to eq(well2.movie_time.to_s)
      expect(well['insert_size']).to eq(well2.insert_size)
      expect(well['on_plate_loading_concentration']).to eq(well2.on_plate_loading_concentration)
      expect(well['pacbio_plate_id']).to eq(well2.pacbio_plate_id)
      expect(well['comment']).to eq(well2.comment)
      expect(well['sequencing_mode']).to eq(well2.sequencing_mode)
      expect(well['pre_extension_time']).to eq(well2.pre_extension_time)
      expect(well['generate_hifi']).to eq(well2.generate_hifi)

      libraries = json['included']
      expect(libraries.length).to eq(2)

      library = libraries[1]['attributes']
      well_library = well2.libraries.last

      expect(library['barcode']).to eq(well_library.barcode)
    end
  end

  context '#create' do

    let(:plate)   { create(:pacbio_plate) }
    let(:request_library1) { create(:pacbio_request_library_with_tag) }
    let(:request_library2) { create(:pacbio_request_library_with_tag) }
    let(:request_library_invalid) { create(:pacbio_request_library_with_tag, tag: request_library1.tag) }

    context 'when creating a single well' do
      context 'on success' do
        let(:body) do
          {
            data: {
              type: "wells",
              attributes: {
                wells: [
                  { row: 'A',
                    column: '1',
                    movie_time: 8,
                    insert_size: 8000,
                    on_plate_loading_concentration: 8.35,
                    sequencing_mode: 'CLR',
                    pre_extension_time: '2',
                    generate_hifi: 'In SMRT Link',
                    relationships: {
                      plate: {
                        data: {
                          type: 'plate',
                          id: plate.id
                        }
                      },
                      libraries: {
                        data: [
                          {
                            type: 'libraries',
                            id: request_library1.library.id
                          },
                          {
                            type: 'libraries',
                            id: request_library2.library.id
                          }
                        ]
                      }
                    }
                  }
                ],
              }
            }
          }.to_json
        end

        it 'has a created status' do
          post v1_pacbio_wells_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created)
        end

        it 'creates a well' do
          expect { post v1_pacbio_wells_path, params: body, headers: json_api_headers }.to change(Pacbio::Well, :count).by(1)
        end

        it 'creates a plate' do
          post v1_pacbio_wells_path, params: body, headers: json_api_headers
          expect(Pacbio::Well.first.plate).to eq(plate)
        end

        it 'creates libraries' do
          post v1_pacbio_wells_path, params: body, headers: json_api_headers
          expect(Pacbio::Well.first.libraries.length).to eq(2)
          expect(Pacbio::Well.first.libraries[0]).to eq(request_library1.library)
          expect(Pacbio::Well.first.libraries[1]).to eq(request_library2.library)
        end

        it 'sends a message to the warehouse' do
          expect(Messages).to receive(:publish)
          post v1_pacbio_wells_path, params: body, headers: json_api_headers
        end
      end

      context 'with pre-extension time set' do
        let(:body) do
          {
            data: {
              type: "wells",
              attributes: {
                wells: [
                  { row: 'A',
                    column: '1',
                    movie_time: 8,
                    insert_size: 8000,
                    on_plate_loading_concentration: 8.36,
                    sequencing_mode: 'CCS',
                    pre_extension_time: 2,
                    generate_hifi: 'In SMRT Link',
                    relationships: {
                      plate: {
                        data: {
                          type: 'plate',
                          id: plate.id
                        }
                      }
                    }
                  },
                  { row: 'B',
                    column: '3',
                    movie_time: 4,
                    insert_size: 7000,
                    on_plate_loading_concentration: 8.83,
                    sequencing_mode: 'CLR',
                    pre_extension_time: 1,
                    generate_hifi: 'In SMRT Link',
                    relationships: {
                      plate: {
                        data: {
                          type: 'plate',
                          id: plate.id
                        }
                      }
                    }
                  }
                ],
              }
            }
          }.to_json
        end

        it 'creates wells with pre-extension time set' do
          post v1_pacbio_wells_path, params: body, headers: json_api_headers
          created_well_id = response.parsed_body['data'][0]['id']
          created_well_2_id = response.parsed_body['data'][1]['id']
          expect(Pacbio::Well.find(created_well_id).pre_extension_time).to eq(2)
          expect(Pacbio::Well.find(created_well_2_id).pre_extension_time).to eq(1)
        end
      end

      context 'on failure' do
        let(:body) do
          {
            data: {
              type: "wells",
              attributes: {
                wells: [
                  row: 'A',
                  column: '1',
                  insert_size: 8000,
                  on_plate_loading_concentration: 8.35,
                  sequencing_mode: 'CLR',
                  generate_hifi: 'In SMRT Link',
                ]
              }
            }
          }.to_json
        end

        it 'has a unprocessable_entity' do
          post v1_pacbio_wells_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not create a well' do
          expect { post v1_pacbio_wells_path, params: body, headers: json_api_headers }.to_not change(Pacbio::Well, :count)
        end

        it 'does not create libraries' do
          expect { post v1_pacbio_wells_path, params: body, headers: json_api_headers }.to_not change(Pacbio::Library, :count)
        end

        it 'has the correct error messages' do
          post v1_pacbio_wells_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['data']['errors']

          expect(errors).to include('plate')
          expect(errors).to include('movie_time')
          expect(errors['plate'][0]).to eq "must exist"
          expect(errors['movie_time'][0]).to eq "can't be blank"
        end

        it 'does not send a message to the warehouse' do
          expect(Messages).to_not receive(:publish)
          post v1_pacbio_wells_path, params: body, headers: json_api_headers
        end

        it 'when no wells exist' do
          body = { data: { type: 'wells', attributes: { wells: [] }}}.to_json
          post v1_pacbio_wells_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['data']['errors']
          expect(errors['wells'][0]).to include "there are no wells"
        end
      end

      context 'on well libraries failure' do
        let(:body) do
          {
            data: {
              type: "wells",
              attributes: {
                wells: [
                  { row: 'A',
                    column: '1',
                    movie_time: 8,
                    insert_size: 8000,
                    on_plate_loading_concentration: 8.35,
                    sequencing_mode: 'CLR',
                    generate_hifi: 'In SMRT Link',
                    relationships: {
                      plate: {
                        data: {
                          type: 'plate',
                          id: plate.id
                        }
                      },
                      libraries: {
                        data: [
                          {
                            type: 'libraries',
                            id: request_library1.library.id
                          },
                          {
                            type: 'libraries',
                            id: request_library_invalid.library.id
                          }
                        ]
                      }
                    }
                  }
                ],
              }
            }
          }.to_json
        end

        it 'has a ok unprocessable_entity' do
          post v1_pacbio_wells_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'has the correct data errors' do
          post v1_pacbio_wells_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['data']['errors']
          expect(errors['tags'][0]).to include "are not unique within the libraries for well"
        end
      end
    end

  end

  context '#update' do
    let(:well) { create(:pacbio_well_with_request_libraries) }
    let(:existing_libraries_data) { well.libraries.map { |l| { type: "libraries", id: l.id } } }

    let(:row) { "A" }
    let(:column) { "1" }
    let(:movie_time) { "15.0" }
    let(:insert_size) { 123 }
    let(:on_plate_loading_concentration) { 12 }
    let(:sequencing_mode) { "CLR" }
    let(:pre_extension_time) { 4 }
    let(:generate_hifi) { "In SMRT Link" }

    context 'when only updating the wells attributes' do
      let(:body) do
        {
          data: {
            id: well.id,
            type: "wells",
            attributes: {
              row: row,
              column: column,
              movie_time: movie_time,
              insert_size: insert_size,
              on_plate_loading_concentration: on_plate_loading_concentration,
              sequencing_mode: sequencing_mode,
              pre_extension_time: pre_extension_time,
              generate_hifi: generate_hifi,
            },
            relationships: {
              libraries: {
                data: existing_libraries_data
              }
            }
          }
        }.to_json
      end

      it 'has a ok status' do
        patch v1_pacbio_well_path(well), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates a wells attributes' do
        patch v1_pacbio_well_path(well), params: body, headers: json_api_headers
        well.reload

        expect(well.row).to eq row
        expect(well.column).to eq column
        expect(well.movie_time.to_i).to eq movie_time.to_i
        expect(well.insert_size.to_i).to eq insert_size.to_i
        expect(well.on_plate_loading_concentration).to eq on_plate_loading_concentration
        expect(well.sequencing_mode).to eq sequencing_mode
        expect(well.pre_extension_time).to eq pre_extension_time
        expect(well.generate_hifi).to eq generate_hifi
      end

      it 'does not update a wells libraries' do
        patch v1_pacbio_well_path(well), params: body, headers: json_api_headers
        well.reload
        expect(well.libraries.length).to eq existing_libraries_data.length
      end

      it 'returns the correct attributes' do
        patch v1_pacbio_well_path(well), params: body, headers: json_api_headers
        json = ActiveSupport::JSON.decode(response.body)
        response = json['data'].first
        expect(response['id'].to_i).to eq well.id
        expect(response['attributes']['insert_size']).to eq insert_size
        expect(response['attributes']['movie_time']).to eq movie_time
        expect(response['attributes']['row']).to eq row
        expect(response['attributes']['column']).to eq column
        expect(response['attributes']['on_plate_loading_concentration']).to eq on_plate_loading_concentration
        expect(response['attributes']['sequencing_mode']).to eq sequencing_mode
        expect(response['attributes']['generate_hifi']).to eq generate_hifi
      end

      it 'sends a message to the warehouse' do
        expect(Messages).to receive(:publish)
        patch v1_pacbio_well_path(well), params: body, headers: json_api_headers
      end
    end

    context 'when successfully adding a new library' do
      let(:tag_set) { create(:tag_set) }
      let(:uniq_tag) { create(:tag, tag_set: tag_set) }
      let(:request_library1) { create(:pacbio_request_library, tag: uniq_tag) }
      let(:updated_libraries_data) { existing_libraries_data.push({ type: "libraries", id: request_library1.library.id }) }

      let(:body) do
        {
          data: {
            id: well.id,
            type: "wells",
            attributes: {
              movie_time: movie_time,
            },
            relationships: {
              libraries: {
                data: updated_libraries_data
              }
            }
          }
        }.to_json
      end

      it 'has a ok status' do
        patch v1_pacbio_well_path(well), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates the wells libraries' do
        patch v1_pacbio_well_path(well), params: body, headers: json_api_headers
        well.reload
        expect(well.libraries.length).to eq updated_libraries_data.length
      end
    end

    context 'when successfully replacing all libraries' do
      let(:request_library1) { create(:pacbio_request_library_with_tag) }
      let(:request_library2) { create(:pacbio_request_library_with_tag) }

      let(:body) do
        {
          data: {
            id: well.id,
            type: "wells",
            attributes: {
              movie_time: movie_time,
            },
            relationships: {
              libraries: {
                data: [
                    {
                      type: "libraries",
                      id: request_library1.library.id
                    },
                    {
                      type: "libraries",
                      id: request_library2.library.id
                    }
                ]
              }
            }
          }
        }.to_json
      end

      it 'has a ok status' do
        patch v1_pacbio_well_path(well), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates the wells libraries' do
        patch v1_pacbio_well_path(well), params: body, headers: json_api_headers
        well.reload
        expect(well.libraries.length).to eq 2
      end
    end

    context 'when successfully removing one library' do
      let(:updated_libraries_data) { existing_libraries_data.slice(1..-1) }

      let(:body) do
        {
          data: {
            id: well.id,
            type: "wells",
            attributes: {
              movie_time: movie_time,
            },
            relationships: {
              libraries: {
                data: updated_libraries_data
              }
            }
          }
        }.to_json
      end

      it 'has a ok status' do
        patch v1_pacbio_well_path(well), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates the wells libraries' do
        patch v1_pacbio_well_path(well), params: body, headers: json_api_headers
        well.reload
        expect(well.libraries.length).to eq updated_libraries_data.length
      end
    end

    context 'when successfully removing all libraries' do
      let(:updated_libraries_data) { existing_libraries_data.slice(1..-1) }

      let(:body) do
        {
          data: {
            id: well.id,
            type: "wells",
            attributes: {
              movie_time: movie_time,
            },
            relationships: {
              libraries: {
                data: []
              }
            }
          }
        }.to_json
      end

      it 'has a ok status' do
        patch v1_pacbio_well_path(well), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates the wells libraries' do
        patch v1_pacbio_well_path(well), params: body, headers: json_api_headers
        well.reload
        expect(well.libraries.length).to eq 0
      end
    end

    context 'on failure' do
      let(:body) do
        {
          data: {
            type: "wells",
            id: 123,
            attributes: {
              "movie_time": 1
            }
          }
        }.to_json
      end

      it 'has a ok unprocessable_entity' do
        patch v1_pacbio_well_path(123), params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        patch v1_pacbio_well_path(123), params: body, headers: json_api_headers
        expect(JSON.parse(response.body)["data"]).to include("errors" => "Couldn't find Pacbio::Well with 'id'=123")
      end

      it 'does not send a message to the warehouse' do
        expect(Messages).to_not receive(:publish)
        patch v1_pacbio_well_path(well), params: body, headers: json_api_headers
      end
    end
  end

  context '#destroy' do
    let!(:well) { create(:pacbio_well) }
    let!(:pacbio_well_library) { create(:pacbio_well_library, well: well) }

    context 'on success' do
      it 'has a status of no content' do
        delete v1_pacbio_well_path(well), headers: json_api_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'deletes the well' do
        expect { delete v1_pacbio_well_path(well), headers: json_api_headers }.to change { Pacbio::Well.count }.by(-1)
      end

      it 'deletes the well library' do
        expect { delete v1_pacbio_well_path(well), headers: json_api_headers }.to change { Pacbio::WellLibrary.count }.by(-1)
      end

      it 'does not delete the library' do
        expect { delete v1_pacbio_well_path(well), headers: json_api_headers }.to change { Pacbio::Library.count }.by(0)
      end
    end

    context 'on failure' do

      it 'does not delete the well' do
        delete "/v1/pacbio/wells/123", headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        delete "/v1/pacbio/wells/123", headers: json_api_headers
        data = JSON.parse(response.body)['data']
        expect(data['errors']).to be_present
      end
    end
  end

end
