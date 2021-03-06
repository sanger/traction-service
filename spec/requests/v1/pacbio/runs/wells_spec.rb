require "rails_helper"

RSpec.describe 'WellsController', type: :request do

  context '#get' do

    let!(:wells) { create_list(:pacbio_well_with_libraries_in_tubes, 2, library_count: 2)}

    it 'returns a list of wells' do
      get v1_pacbio_runs_wells_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get "#{v1_pacbio_runs_wells_path}?include=libraries.tube", headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      well = wells.first
      well_attributes = json['data'][0]['attributes']
      expect(well_attributes['pacbio_plate_id']).to eq(well.pacbio_plate_id)
      expect(well_attributes['row']).to eq(well.row)
      expect(well_attributes['column']).to eq(well.column)
      # TODO: fix movie time column
      expect(well_attributes['movie_time'].to_s).to eq(well.movie_time.to_s)
      expect(well_attributes['insert_size']).to eq(well.insert_size)
      expect(well_attributes['on_plate_loading_concentration']).to eq(well.on_plate_loading_concentration)
      expect(well_attributes['pacbio_plate_id']).to eq(well.pacbio_plate_id)
      expect(well_attributes['comment']).to eq(well.comment)
      expect(well_attributes['pre_extension_time']).to eq(well.pre_extension_time)
      expect(well_attributes['generate_hifi']).to eq(well.generate_hifi)
      expect(well_attributes['ccs_analysis_output']).to eq(well.ccs_analysis_output)

      tube = json['included'][4]['attributes']
      expect(tube['barcode']).to eq(well.libraries.first.tube.barcode)
    end
  end

  context '#create' do

    let(:plate)   { create(:pacbio_plate) }
    let(:library1) { create(:pacbio_library_with_tag) }
    let(:library2) { create(:pacbio_library_with_tag) }
    let(:library_invalid) { create(:pacbio_library_with_tag, tag: library1.tag) }

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
                    pre_extension_time: '2',
                    generate_hifi: 'In SMRT Link',
                    ccs_analysis_output: 'Yes',
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
                            id: library1.id
                          },
                          {
                            type: 'libraries',
                            id: library2.id
                          }
                        ]
                      }
                    }
                  },
                  { row: 'B',
                    column: '3',
                    movie_time: 4,
                    insert_size: 7000,
                    on_plate_loading_concentration: 8.83,
                    pre_extension_time: 1,
                    generate_hifi: 'In SMRT Link',
                    ccs_analysis_output: 'Yes',
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

        it 'has a created status' do
          post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created)
        end

        it 'creates a well' do
          expect { post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers }.to change(Pacbio::Well, :count).by(2)
        end

        it 'creates wells with the correct attributes' do
          post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers
          created_well_id = response.parsed_body['data'][0]['id']
          created_well_2_id = response.parsed_body['data'][1]['id']
          expect(Pacbio::Well.find(created_well_id).pre_extension_time).to eq(2)
          expect(Pacbio::Well.find(created_well_2_id).pre_extension_time).to eq(1)
          expect(Pacbio::Well.find(created_well_id).generate_hifi).to eq("In SMRT Link")
          expect(Pacbio::Well.find(created_well_id).ccs_analysis_output).to eq("Yes")
          expect(Pacbio::Well.find(created_well_2_id).generate_hifi).to eq("In SMRT Link")
          expect(Pacbio::Well.find(created_well_2_id).ccs_analysis_output).to eq("Yes")
        end

        it 'creates a plate' do
          post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers
          expect(Pacbio::Well.first.plate).to eq(plate)
        end

        it 'creates libraries' do
          post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers
          expect(Pacbio::Well.first.libraries.length).to eq(2)
          expect(Pacbio::Well.first.libraries[0]).to eq(library1)
          expect(Pacbio::Well.first.libraries[1]).to eq(library2)
        end

        it 'sends a message to the warehouse' do
          expect(Messages).to receive(:publish)
          post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers
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
                  generate_hifi: 'In SMRT Link',
                  ccs_analysis_output: 'Yes',
                ]
              }
            }
          }.to_json
        end

        it 'has a unprocessable_entity' do
          post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not create a well' do
          expect { post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers }.to_not change(Pacbio::Well, :count)
        end

        it 'does not create libraries' do
          expect { post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers }.to_not change(Pacbio::Library, :count)
        end

        it 'has the correct error messages' do
          post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['data']['errors']

          expect(errors).to include('plate')
          expect(errors).to include('movie_time')
          expect(errors['plate'][0]).to eq "must exist"
          expect(errors['movie_time'][0]).to eq "can't be blank"
        end

        it 'does not send a message to the warehouse' do
          expect(Messages).to_not receive(:publish)
          post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers
        end

        it 'when no wells exist' do
          body = { data: { type: 'wells', attributes: { wells: [] }}}.to_json
          post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers
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
                    generate_hifi: 'In SMRT Link',
                    ccs_analysis_output: 'Yes',
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
                            id: library1.id
                          },
                          {
                            type: 'libraries',
                            id: library_invalid.id
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
          post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'has the correct data errors' do
          post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['data']['errors']
          expect(errors['tags'][0]).to include "are not unique within the libraries for well"
        end
      end
    end

  end

  context '#update' do
    let(:well) { create(:pacbio_well_with_libraries) }
    let(:existing_libraries_data) { well.libraries.map { |l| { type: "libraries", id: l.id } } }

    let(:row) { "A" }
    let(:column) { "1" }
    let(:movie_time) { "15.0" }
    let(:insert_size) { 123 }
    let(:on_plate_loading_concentration) { 12 }
    let(:pre_extension_time) { 4 }
    let(:generate_hifi) { 'Do Not Generate' }
    let(:ccs_analysis_output) { 'No' }

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
              pre_extension_time: pre_extension_time,
              generate_hifi: generate_hifi,
              ccs_analysis_output: ccs_analysis_output,
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
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates a wells attributes' do
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
        well.reload

        expect(well.row).to eq row
        expect(well.column).to eq column
        expect(well.movie_time.to_i).to eq movie_time.to_i
        expect(well.insert_size.to_i).to eq insert_size.to_i
        expect(well.on_plate_loading_concentration).to eq on_plate_loading_concentration
        expect(well.pre_extension_time).to eq pre_extension_time
        expect(well.generate_hifi).to eq generate_hifi
        expect(well.ccs_analysis_output).to eq ccs_analysis_output
      end

      it 'does not update a wells libraries' do
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
        well.reload
        expect(well.libraries.length).to eq existing_libraries_data.length
      end

      it 'returns the correct attributes' do
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
        json = ActiveSupport::JSON.decode(response.body)
        response = json['data'].first
        expect(response['id'].to_i).to eq well.id
        expect(response['attributes']['insert_size']).to eq insert_size
        expect(response['attributes']['movie_time']).to eq movie_time
        expect(response['attributes']['row']).to eq row
        expect(response['attributes']['column']).to eq column
        expect(response['attributes']['on_plate_loading_concentration']).to eq on_plate_loading_concentration
        expect(response['attributes']['generate_hifi']).to eq generate_hifi
        expect(response['attributes']['ccs_analysis_output']).to eq ccs_analysis_output
      end

      it 'sends a message to the warehouse' do
        expect(Messages).to receive(:publish)
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
      end
    end

    context 'when successfully adding a new library' do
      let(:tag_set) { create(:tag_set) }
      let(:uniq_tag) { create(:tag, tag_set: tag_set) }
      let(:library1) { create(:pacbio_library, tag: uniq_tag) }
      let(:updated_libraries_data) { existing_libraries_data.push({ type: "libraries", id: library1.id }) }

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
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates the wells libraries' do
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
        well.reload
        expect(well.libraries.length).to eq updated_libraries_data.length
      end
    end

    context 'when successfully replacing all libraries' do
      let(:library1) { create(:pacbio_library_with_tag) }
      let(:library2) { create(:pacbio_library_with_tag) }

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
                      id: library1.id
                    },
                    {
                      type: "libraries",
                      id: library2.id
                    }
                ]
              }
            }
          }
        }.to_json
      end

      it 'has a ok status' do
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates the wells libraries' do
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
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
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates the wells libraries' do
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
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
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates the wells libraries' do
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
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
        patch v1_pacbio_runs_well_path(123), params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        patch v1_pacbio_runs_well_path(123), params: body, headers: json_api_headers
        expect(JSON.parse(response.body)["data"]).to include("errors" => "Couldn't find Pacbio::Well with 'id'=123")
      end

      it 'does not send a message to the warehouse' do
        expect(Messages).to_not receive(:publish)
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
      end
    end
  end

  context '#destroy' do
    let!(:well) { create(:pacbio_well) }
    let!(:pacbio_well_library) { create(:pacbio_well_library, well: well) }

    context 'on success' do
      it 'has a status of no content' do
        delete v1_pacbio_runs_well_path(well), headers: json_api_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'deletes the well' do
        expect { delete v1_pacbio_runs_well_path(well), headers: json_api_headers }.to change { Pacbio::Well.count }.by(-1)
      end

      it 'deletes the well library' do
        expect { delete v1_pacbio_runs_well_path(well), headers: json_api_headers }.to change { Pacbio::WellLibrary.count }.by(-1)
      end

      it 'does not delete the library' do
        expect { delete v1_pacbio_runs_well_path(well), headers: json_api_headers }.to change { Pacbio::Library.count }.by(0)
      end
    end

    context 'on failure' do

      it 'does not delete the well' do
        delete "/v1/pacbio/runs/wells/123", headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        delete "/v1/pacbio/runs/wells/123", headers: json_api_headers
        data = JSON.parse(response.body)['data']
        expect(data['errors']).to be_present
      end
    end
  end

end
