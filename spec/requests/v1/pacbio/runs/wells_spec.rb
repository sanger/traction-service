# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'WellsController', type: :request do
  describe '#get' do
    let!(:wells) { create_list(:pacbio_well_with_pools, 2, pool_count: 2) }

    it 'returns a list of wells' do
      get v1_pacbio_runs_wells_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get "#{v1_pacbio_runs_wells_path}?include=pools", headers: json_api_headers

      expect(response).to have_http_status(:success), response.body
      well = wells.first
      well_attributes = json['data'][0]['attributes']
      expect(well_attributes['pacbio_plate_id']).to eq(well.pacbio_plate_id)
      expect(well_attributes['row']).to eq(well.row)
      expect(well_attributes['column']).to eq(well.column)
      # TODO: fix movie time column
      expect(well_attributes['movie_time'].to_s).to eq(well.movie_time.to_s)
      expect(well_attributes['on_plate_loading_concentration']).to eq(well.on_plate_loading_concentration)
      expect(well_attributes['pacbio_plate_id']).to eq(well.pacbio_plate_id)
      expect(well_attributes['comment']).to eq(well.comment)
      expect(well_attributes['pre_extension_time']).to eq(well.pre_extension_time)
      expect(well_attributes['generate_hifi']).to eq(well.generate_hifi)
      expect(well_attributes['ccs_analysis_output']).to eq(well.ccs_analysis_output)
      expect(well_attributes['binding_kit_box_barcode']).to eq(well.binding_kit_box_barcode)
    end
  end

  describe '#create' do
    let(:plate)    { create(:pacbio_plate) }
    let(:pool1)    { create(:pacbio_pool) }
    let(:pool2)    { create(:pacbio_pool) }

    context 'when creating a single well' do
      context 'on success' do
        let(:body) do
          {
            data: {
              type: 'wells',
              attributes: {
                wells: [
                  { row: 'A',
                    column: '1',
                    movie_time: 8,
                    on_plate_loading_concentration: 8.35,
                    pre_extension_time: '2',
                    generate_hifi: 'In SMRT Link',
                    ccs_analysis_output: 'Yes',
                    binding_kit_box_barcode: 'DM1117100862200111711',
                    relationships: {
                      plate: {
                        data: {
                          type: 'plate',
                          id: plate.id
                        }
                      },
                      pools: {
                        data: [
                          {
                            type: 'pools',
                            id: pool1.id
                          },
                          {
                            type: 'libraries',
                            id: pool2.id
                          }
                        ]
                      }
                    } },
                  { row: 'B',
                    column: '3',
                    movie_time: 4,
                    on_plate_loading_concentration: 8.83,
                    pre_extension_time: 1,
                    generate_hifi: 'In SMRT Link',
                    ccs_analysis_output: 'Yes',
                    binding_kit_box_barcode: 'DM1117100862200111711',
                    relationships: {
                      plate: {
                        data: {
                          type: 'plate',
                          id: plate.id
                        }
                      }
                    } }
                ]
              }
            }
          }.to_json
        end

        it 'has a created status' do
          post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created)
        end

        it 'creates a well' do
          expect do
            post v1_pacbio_runs_wells_path, params: body,
                                            headers: json_api_headers
          end.to change(Pacbio::Well, :count).by(2)
        end

        it 'creates wells with the correct attributes' do
          post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers
          created_well_id = response.parsed_body['data'][0]['id']
          created_well_2_id = response.parsed_body['data'][1]['id']
          expect(Pacbio::Well.find(created_well_id).pre_extension_time).to eq(2)
          expect(Pacbio::Well.find(created_well_2_id).pre_extension_time).to eq(1)
          expect(Pacbio::Well.find(created_well_id).generate_hifi).to eq('In SMRT Link')
          expect(Pacbio::Well.find(created_well_2_id).generate_hifi).to eq('In SMRT Link')
          expect(Pacbio::Well.find(created_well_id).ccs_analysis_output).to eq('Yes')
          expect(Pacbio::Well.find(created_well_2_id).ccs_analysis_output).to eq('Yes')
          expect(Pacbio::Well.find(created_well_id).binding_kit_box_barcode).to eq('DM1117100862200111711')
          expect(Pacbio::Well.find(created_well_2_id).binding_kit_box_barcode).to eq('DM1117100862200111711')
        end

        it 'creates a plate' do
          post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers
          expect(Pacbio::Well.first.plate).to eq(plate)
        end

        it 'creates pools' do
          post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers
          expect(Pacbio::Well.first.pools.length).to eq(2)
          expect(Pacbio::Well.first.pools[0]).to eq(pool1)
          expect(Pacbio::Well.first.pools[1]).to eq(pool2)
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
              type: 'wells',
              attributes: {
                wells: [
                  row: 'A',
                  column: '1',
                  on_plate_loading_concentration: 8.35,
                  generate_hifi: 'In SMRT Link',
                  ccs_analysis_output: 'Yes',
                  binding_kit_box_barcode: 'DM1117100862200111711'
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
          expect do
            post v1_pacbio_runs_wells_path, params: body,
                                            headers: json_api_headers
          end.not_to change(Pacbio::Well, :count)
        end

        it 'does not create pools' do
          expect do
            post v1_pacbio_runs_wells_path, params: body,
                                            headers: json_api_headers
          end.not_to change(Pacbio::Pool, :count)
        end

        it 'has the correct error messages' do
          post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['data']['errors']

          expect(errors).to include('plate')
          expect(errors).to include('movie_time')
          expect(errors['plate'][0]).to eq 'must exist'
          expect(errors['movie_time'][0]).to eq "can't be blank"
        end

        it 'does not send a message to the warehouse' do
          expect(Messages).not_to receive(:publish)
          post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers
        end

        it 'when no wells exist' do
          body = { data: { type: 'wells', attributes: { wells: [] } } }.to_json
          post v1_pacbio_runs_wells_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['data']['errors']
          expect(errors['wells']).not_to be_empty
        end
      end
    end
  end

  describe '#update' do
    let(:well) { create(:pacbio_well_with_pools) }
    let(:existing_pools_data) { well.pools.map { |p| { type: 'pools', id: p.id } } }

    let(:row) { 'A' }
    let(:column) { '1' }
    let(:movie_time) { '15.0' }
    let(:on_plate_loading_concentration) { 12 }
    let(:pre_extension_time) { 4 }
    let(:generate_hifi) { 'Do Not Generate' }
    let(:ccs_analysis_output) { 'No' }
    let(:binding_kit_box_barcode) { 'DM1117100862200111711' }

    context 'when only updating the wells attributes' do
      let(:body) do
        {
          data: {
            id: well.id,
            type: 'wells',
            attributes: {
              row: row,
              column: column,
              movie_time: movie_time,
              on_plate_loading_concentration: on_plate_loading_concentration,
              pre_extension_time: pre_extension_time,
              generate_hifi: generate_hifi,
              ccs_analysis_output: ccs_analysis_output,
              binding_kit_box_barcode: binding_kit_box_barcode
            },
            relationships: {
              pools: {
                data: existing_pools_data
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
        expect(well.on_plate_loading_concentration).to eq on_plate_loading_concentration
        expect(well.pre_extension_time).to eq pre_extension_time
        expect(well.generate_hifi).to eq generate_hifi
        expect(well.ccs_analysis_output).to eq ccs_analysis_output
        expect(well.binding_kit_box_barcode).to eq binding_kit_box_barcode
      end

      it 'does not update a wells pools' do
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
        well.reload
        expect(well.pools.length).to eq existing_pools_data.length
      end

      it 'returns the correct attributes' do
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
        json = ActiveSupport::JSON.decode(response.body)
        response = json['data'].first
        expect(response['id'].to_i).to eq well.id
        expect(response['attributes']['movie_time']).to eq movie_time
        expect(response['attributes']['row']).to eq row
        expect(response['attributes']['column']).to eq column
        expect(response['attributes']['on_plate_loading_concentration']).to eq on_plate_loading_concentration
        expect(response['attributes']['generate_hifi']).to eq generate_hifi
        expect(response['attributes']['ccs_analysis_output']).to eq ccs_analysis_output
        expect(response['attributes']['binding_kit_box_barcode']).to eq binding_kit_box_barcode
      end

      it 'sends a message to the warehouse' do
        expect(Messages).to receive(:publish)
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
      end
    end

    context 'when successfully adding a new pool' do
      let(:pool1) { create(:pacbio_pool) }
      let(:updated_pools_data) { existing_pools_data.push({ type: 'pools', id: pool1.id }) }

      let(:body) do
        {
          data: {
            id: well.id,
            type: 'wells',
            attributes: {
              movie_time: movie_time
            },
            relationships: {
              pools: {
                data: updated_pools_data
              }
            }
          }
        }.to_json
      end

      it 'has a ok status' do
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates the wells pools' do
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
        well.reload
        expect(well.pools.length).to eq updated_pools_data.length
      end
    end

    context 'when successfully replacing all pools' do
      let(:pool1) { create(:pacbio_pool) }
      let(:pool2) { create(:pacbio_pool) }

      let(:body) do
        {
          data: {
            id: well.id,
            type: 'wells',
            attributes: {
              movie_time: movie_time
            },
            relationships: {
              pools: {
                data: [
                  {
                    type: 'pools',
                    id: pool1.id
                  },
                  {
                    type: 'pools',
                    id: pool2.id
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

      it 'updates the wells pools' do
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
        well.reload
        expect(well.pools.length).to eq 2
      end
    end

    context 'when successfully removing one pool' do
      let(:updated_pools_data) { existing_pools_data.slice(1..-1) }

      let(:body) do
        {
          data: {
            id: well.id,
            type: 'wells',
            attributes: {
              movie_time: movie_time
            },
            relationships: {
              pools: {
                data: updated_pools_data
              }
            }
          }
        }.to_json
      end

      it 'has a ok status' do
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates the wells pools' do
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
        well.reload
        expect(well.pools.length).to eq updated_pools_data.length
      end
    end

    context 'when successfully removing all pools' do
      let(:body) do
        {
          data: {
            id: well.id,
            type: 'wells',
            attributes: {
              movie_time: movie_time
            },
            relationships: {
              pools: {
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

      it 'updates the wells pools' do
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
        well.reload
        expect(well.pools.length).to eq 0
      end
    end

    context 'on failure' do
      let(:body) do
        {
          data: {
            type: 'wells',
            id: 123,
            attributes: {
              movie_time: 1
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
        expect(JSON.parse(response.body)['data']).to include('errors' => "Couldn't find Pacbio::Well with 'id'=123")
      end

      it 'does not send a message to the warehouse' do
        expect(Messages).not_to receive(:publish)
        patch v1_pacbio_runs_well_path(well), params: body, headers: json_api_headers
      end
    end
  end

  describe '#destroy' do
    let!(:well) { create(:pacbio_well) }
    let!(:pacbio_well_pool) { create(:pacbio_well_pool, well: well) }

    context 'on success' do
      it 'has a status of no content' do
        delete v1_pacbio_runs_well_path(well), headers: json_api_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'deletes the well' do
        expect { delete v1_pacbio_runs_well_path(well), headers: json_api_headers }.to change {
                                                                                         Pacbio::Well.count
                                                                                       }.by(-1)
      end

      it 'deletes the well pool' do
        expect { delete v1_pacbio_runs_well_path(well), headers: json_api_headers }.to change {
                                                                                         Pacbio::WellPool.count
                                                                                       }.by(-1)
      end

      it 'does not delete the pool' do
        expect { delete v1_pacbio_runs_well_path(well), headers: json_api_headers }.to change {
                                                                                         Pacbio::Pool.count
                                                                                       }.by(0)
      end
    end

    context 'on failure' do
      it 'does not delete the well' do
        delete '/v1/pacbio/runs/wells/123', headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        delete '/v1/pacbio/runs/wells/123', headers: json_api_headers
        data = JSON.parse(response.body)['data']
        expect(data['errors']).to be_present
      end
    end
  end
end
