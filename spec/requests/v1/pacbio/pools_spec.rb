# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PoolsController', :pacbio do
  before do
    # Create a default smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version_default)
  end

  let!(:request) { create(:pacbio_request) }
  let!(:tag) { create(:tag) }
  let!(:request2) { create(:pacbio_request) }
  let!(:tag2) { create(:tag) }

  describe '#get' do
    let!(:pools) { create_list(:pacbio_pool, 2) }

    it 'returns a list of pools' do
      get v1_pacbio_pools_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      expect(json['data'].length).to eq(2)
    end

    it 'returns pool attributes', :aggregate_failures do
      get v1_pacbio_pools_path, headers: json_api_headers

      expect(response).to have_http_status(:success)

      pool = pools.first
      pool_resource = find_resource(id: pool.id, type: 'pools')

      expect(pool_resource['attributes']).to include(
        'source_identifier' => pool.source_identifier,
        'volume' => pool.volume,
        'concentration' => pool.concentration,
        'template_prep_kit_box_barcode' => pool.template_prep_kit_box_barcode,
        'insert_size' => pool.insert_size,
        'created_at' => pool.created_at.to_fs(:us)
      )
    end

    it 'includes pool run suitability' do
      get v1_pacbio_pools_path, headers: json_api_headers
      pool_resource = find_resource(id: pools.first.id, type: 'pools')
      expect(pool_resource.dig('attributes', 'run_suitability')).to eq({
                                                                         'ready_for_run' => true,
                                                                         'errors' => []
                                                                       })
    end

    context 'when not suited for run creation' do
      let!(:pools) { create_list(:pacbio_pool, 2, insert_size: nil) }

      it 'includes invalid pool run suitability' do
        get v1_pacbio_pools_path, headers: json_api_headers
        pool_resource = find_resource(id: pools.first.id, type: 'pools')
        run_suitability = pool_resource.dig('attributes', 'run_suitability')
        expect(run_suitability).to eq({
                                        'ready_for_run' => false,
                                        'errors' => [
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

    it 'returns the correct attributes', :aggregate_failures do
      get "#{v1_pacbio_pools_path}?include=libraries", headers: json_api_headers

      expect(response).to have_http_status(:success)

      library_attributes = json['included'][0]['attributes']
      library = pools.first.libraries.first

      expect(library_attributes['volume']).to eq(library.volume)
      expect(library_attributes['concentration']).to eq(library.concentration)
      expect(library_attributes['template_prep_kit_box_barcode']).to eq(library.template_prep_kit_box_barcode)
      expect(library_attributes['insert_size']).to eq(library.insert_size)
    end

    context 'with includes' do
      before do
        get "#{v1_pacbio_pools_path}?include=libraries,primary_aliquot,used_aliquots.source,used_aliquots.tag,tube",
            headers: json_api_headers
      end

      let(:pool) { pools.first }

      it 'has a success status' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the correct included data', :aggregate_failures do
        libraries_resource = find_included_resource(type: 'library_pools', id: pool.libraries.first.id)
        expect(libraries_resource['id']).to eq(pool.libraries.first.id.to_s)
        expect(libraries_resource['type']).to eq('library_pools')

        primary_aliquot_resource = find_included_resource(type: 'aliquots', id: pool.primary_aliquot.id)
        expect(primary_aliquot_resource['id']).to eq(pool.primary_aliquot.id.to_s)
        expect(primary_aliquot_resource['type']).to eq('aliquots')

        used_aliquot_resource = find_included_resource(type: 'aliquots', id: pool.used_aliquots.first.id)
        expect(used_aliquot_resource['id']).to eq(pool.used_aliquots.first.id.to_s)
        expect(used_aliquot_resource['type']).to eq('aliquots')
        expect(used_aliquot_resource.dig('attributes', 'run_suitability')).to eq({
                                                                                   'ready_for_run' => true,
                                                                                   'errors' => []
                                                                                 })

        used_aliquot_source_resource = find_included_resource(type: 'requests', id: pool.used_aliquots.first.source_id)
        expect(used_aliquot_source_resource['id']).to eq(pool.used_aliquots.first.source_id.to_s)
        expect(used_aliquot_source_resource['type']).to eq('requests')

        used_aliquot_tag_resource = find_included_resource(type: 'tags', id: pool.used_aliquots.first.tag_id)
        expect(used_aliquot_tag_resource['id']).to eq(pool.used_aliquots.first.tag_id.to_s)
        expect(used_aliquot_tag_resource['type']).to eq('tags')

        tube_resource = find_included_resource(type: 'tubes', id: pool.tube.id)
        expect(tube_resource['id']).to eq(pool.tube.id.to_s)
        expect(tube_resource['type']).to eq('tubes')
        expect(tube_resource['attributes']['barcode']).to eq(pool.tube.barcode)
      end
    end

    context 'pagination' do
      let!(:expected_pools) { create_list(:pacbio_pool, 2, created_at: Time.zone.now + 10) }

      before do
        # There should be 4 pools total so we should get the 2 we just created
        get "#{v1_pacbio_pools_path}?page[number]=1&page[size]=2",
            headers: json_api_headers
      end

      it 'has a success status' do
        expect(response).to have_http_status(:success), response.body
      end

      it 'returns a list of pools' do
        expect(json['data'].length).to eq(2)
      end

      it 'returns the correct attributes', :aggregate_failures do
        expected_pools.each do |pool|
          pool_attributes = find_resource(type: 'pools', id: pool.id)['attributes']
          expect(pool_attributes).to include(
            'source_identifier' => pool.source_identifier,
            'volume' => pool.volume,
            'concentration' => pool.concentration,
            'template_prep_kit_box_barcode' => pool.template_prep_kit_box_barcode,
            'insert_size' => pool.insert_size,
            'updated_at' => pool.updated_at.to_fs(:us),
            'created_at' => pool.created_at.to_fs(:us)
          )
        end
      end
    end
  end

  describe '#create via libraries' do
    context 'when creating a singleplex library' do
      context 'on success' do
        let(:body) do
          {
            data: {
              type: 'pools',
              attributes: {
                template_prep_kit_box_barcode: 'LK1234567',
                volume: 1.11,
                concentration: 2.22,
                insert_size: 100,
                library_attributes: [
                  {
                    volume: 1.11,
                    template_prep_kit_box_barcode: 'LK1234567',
                    concentration: 2.22,
                    insert_size: 100,
                    pacbio_request_id: request.id,
                    tag_id: tag.id
                  }
                ],
                primary_aliquot_attributes: {
                  volume: '200',
                  concentration: '22',
                  template_prep_kit_box_barcode: '100',
                  insert_size: '11'
                }
              }
            }
          }.to_json
        end

        it 'has a created status' do
          post v1_pacbio_pools_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created), response.body
        end

        it 'creates a pool' do
          expect { post v1_pacbio_pools_path, params: body, headers: json_api_headers }.to change(Pacbio::Pool, :count).by(1)
        end

        it 'returns the id' do
          post v1_pacbio_pools_path, params: body, headers: json_api_headers
          expect(json.dig('data', 'id').to_i).to eq(Pacbio::Pool.first.id)
        end

        it 'includes the tube' do
          post "#{v1_pacbio_pools_path}?include=tube", params: body, headers: json_api_headers
          tube = find_included_resource(id: Pacbio::Pool.first.tube_id, type: 'tubes')
          expect(tube.dig('attributes', 'barcode')).to be_present
        end
      end

      context 'on failure - when library is invalid' do
        let(:body) do
          {
            data: {
              type: 'pools',
              attributes: {
                library_attributes: [
                  {
                    template_prep_kit_box_barcode: 'LK1234567',
                    volume: 1.11,
                    concentration: 2.22,
                    insert_size: 'Sausages',
                    pacbio_request_id: request.id,
                    tag_id: tag.id
                  }
                ],
                primary_aliquot_attributes: {
                  volume: '200',
                  concentration: '22',
                  template_prep_kit_box_barcode: '100',
                  insert_size: '11'
                }
              }
            }
          }.to_json
        end

        it 'returns unprocessable entity status' do
          post v1_pacbio_pools_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'cannot create a pool' do
          expect { post v1_pacbio_pools_path, params: body, headers: json_api_headers }.not_to(
            change(Pacbio::Pool, :count)
          )
        end
      end
    end

    context 'when creating a multiplex library' do
      context 'on success' do
        let(:body) do
          {
            data: {
              type: 'pools',
              attributes: {
                library_attributes: [
                  {
                    template_prep_kit_box_barcode: 'LK1234567',
                    volume: 1.11,
                    concentration: 2.22,
                    insert_size: 100,
                    pacbio_request_id: request.id,
                    tag_id: tag.id
                  },
                  {
                    template_prep_kit_box_barcode: 'LK1234567',
                    volume: 1.11,
                    concentration: 2.22,
                    insert_size: 100,
                    pacbio_request_id: request2.id,
                    tag_id: tag2.id
                  }
                ],
                primary_aliquot_attributes: {
                  volume: '200',
                  concentration: '22',
                  template_prep_kit_box_barcode: '100',
                  insert_size: '11'
                }
              }
            }
          }.to_json
        end

        it 'returns created status' do
          post v1_pacbio_pools_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created)
        end

        it 'creates a pool, library and aliquots' do
          expect { post v1_pacbio_pools_path, params: body, headers: json_api_headers }.to(
            change(Pacbio::Pool, :count).by(1).and(
              change(Pacbio::Library, :count).by(2).and(
                change(Aliquot, :count).by(3)
              )
            )
          )
        end
      end

      context 'on failure - when there is a tag clash' do
        let(:body) do
          {
            data: {
              type: 'pools',
              attributes: {
                library_attributes: [
                  {
                    template_prep_kit_box_barcode: 'LK1234567',
                    volume: 1.11,
                    concentration: 2.22,
                    insert_size: 100,
                    pacbio_request_id: request.id,
                    tag_id: tag.id
                  },
                  {
                    template_prep_kit_box_barcode: 'LK1234567',
                    volume: 1.11,
                    concentration: 2.22,
                    insert_size: 100,
                    pacbio_request_id: request2.id,
                    tag_id: tag.id
                  }
                ],
                primary_aliquot_attributes: {
                  volume: '200',
                  concentration: '22',
                  template_prep_kit_box_barcode: '100',
                  insert_size: '11'
                }
              }
            }
          }.to_json
        end

        it 'returns unprocessable entity status' do
          post v1_pacbio_pools_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'cannot create a pool' do
          expect { post v1_pacbio_pools_path, params: body, headers: json_api_headers }.not_to(
            change(Pacbio::Pool, :count)
          )
        end
      end

      context 'on failure - when there is aliquot id thats not part of the pool' do
        let(:additional_library) { create(:pacbio_library) }
        let(:body) do
          {
            data: {
              type: 'pools',
              attributes: {
                library_attributes: [
                  {
                    id: additional_library.id.to_s,
                    template_prep_kit_box_barcode: 'LK1234567',
                    volume: 1.11,
                    concentration: 2.22,
                    insert_size: 100,
                    pacbio_request_id: request.id,
                    tag_id: tag.id
                  },
                  {
                    template_prep_kit_box_barcode: 'LK1234567',
                    volume: 1.11,
                    concentration: 2.22,
                    insert_size: 100,
                    pacbio_request_id: request2.id,
                    tag_id: tag2.id
                  }
                ],
                primary_aliquot_attributes: {
                  volume: '200',
                  concentration: '22',
                  template_prep_kit_box_barcode: '100',
                  insert_size: '11'
                }
              }
            }
          }.to_json
        end

        it 'returns internal_server_error status' do
          post v1_pacbio_pools_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:internal_server_error)
          expect(response.body).to include('Aliquot is not part of the pool')
        end

        it 'cannot create a pool' do
          expect { post v1_pacbio_pools_path, params: body, headers: json_api_headers }.not_to(
            change(Pacbio::Pool, :count)
          )
        end
      end
    end
  end

  describe '#create via aliquots' do
    context 'when creating a singleplex library' do
      context 'on success' do
        let(:body) do
          {
            data: {
              type: 'pools',
              attributes: {
                template_prep_kit_box_barcode: 'LK1234567',
                volume: 1.11,
                concentration: 2.22,
                insert_size: 100,
                used_aliquots_attributes: [
                  {
                    volume: 1.11,
                    template_prep_kit_box_barcode: 'LK1234567',
                    concentration: 2.22,
                    insert_size: 100,
                    source_id: request.id,
                    source_type: 'Pacbio::Request',
                    tag_id: tag.id
                  }
                ],
                primary_aliquot_attributes: {
                  volume: '200',
                  concentration: '22',
                  template_prep_kit_box_barcode: '100',
                  insert_size: '11'
                }
              }
            }
          }.to_json
        end

        it 'has a created status' do
          post v1_pacbio_pools_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created), response.body
        end

        it 'creates a pool' do
          expect { post v1_pacbio_pools_path, params: body, headers: json_api_headers }.to change(Pacbio::Pool, :count).by(1)
        end

        it 'returns the id' do
          post v1_pacbio_pools_path, params: body, headers: json_api_headers
          expect(json.dig('data', 'id').to_i).to eq(Pacbio::Pool.first.id)
        end

        it 'includes the tube' do
          post "#{v1_pacbio_pools_path}?include=tube", params: body, headers: json_api_headers
          tube = find_included_resource(id: Pacbio::Pool.first.tube_id, type: 'tubes')
          expect(tube.dig('attributes', 'barcode')).to be_present
        end
      end

      context 'on failure - when used_aliquot is invalid' do
        let(:body) do
          {
            data: {
              type: 'pools',
              attributes: {
                used_aliquots_attributes: [
                  {
                    template_prep_kit_box_barcode: 'LK1234567',
                    volume: 1.11,
                    concentration: 2.22,
                    insert_size: 'Sausages',
                    source_id: request.id,
                    source_type: 'Pacbio::Request',
                    tag_id: tag.id
                  }
                ],
                primary_aliquot_attributes: {
                  volume: '200',
                  concentration: '22',
                  template_prep_kit_box_barcode: '100',
                  insert_size: '11'
                }
              }
            }
          }.to_json
        end

        it 'returns unprocessable entity status' do
          post v1_pacbio_pools_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'cannot create a pool' do
          expect { post v1_pacbio_pools_path, params: body, headers: json_api_headers }.not_to(
            change(Pacbio::Pool, :count)
          )
        end
      end
    end

    context 'when creating a multiplex library' do
      context 'on success' do
        let(:body) do
          {
            data: {
              type: 'pools',
              attributes: {
                used_aliquots_attributes: [
                  {
                    template_prep_kit_box_barcode: 'LK1234567',
                    volume: 1.11,
                    concentration: 2.22,
                    insert_size: 100,
                    source_id: request.id,
                    source_type: 'Pacbio::Request',
                    tag_id: tag.id
                  },
                  {
                    template_prep_kit_box_barcode: 'LK1234567',
                    volume: 1.11,
                    concentration: 2.22,
                    insert_size: 100,
                    source_id: request2.id,
                    source_type: 'Pacbio::Request',
                    tag_id: tag2.id
                  }
                ],
                primary_aliquot_attributes: {
                  volume: '200',
                  concentration: '22',
                  template_prep_kit_box_barcode: '100',
                  insert_size: '11'
                }
              }
            }
          }.to_json
        end

        it 'returns created status' do
          post v1_pacbio_pools_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created)
        end

        it 'creates a pool' do
          expect { post v1_pacbio_pools_path, params: body, headers: json_api_headers }.to(
            change(Pacbio::Pool, :count).by(1).and(
              change(Pacbio::Library, :count).by(2).and(
                change(Aliquot, :count).by(3)
              )
            )
          )
        end
      end

      context 'on failure - when there is a tag clash' do
        let(:body) do
          {
            data: {
              type: 'pools',
              attributes: {
                used_aliquots_attributes: [
                  {
                    template_prep_kit_box_barcode: 'LK1234567',
                    volume: 1.11,
                    concentration: 2.22,
                    insert_size: 100,
                    source_id: request.id,
                    source_type: 'Pacbio::Request',
                    tag_id: tag.id
                  },
                  {
                    template_prep_kit_box_barcode: 'LK1234567',
                    volume: 1.11,
                    concentration: 2.22,
                    insert_size: 100,
                    source_id: request2.id,
                    source_type: 'Pacbio::Request',
                    tag_id: tag.id
                  }
                ],
                primary_aliquot_attributes: {
                  volume: '200',
                  concentration: '22',
                  template_prep_kit_box_barcode: '100',
                  insert_size: '11'
                }
              }
            }
          }.to_json
        end

        it 'returns unprocessable entity status' do
          post v1_pacbio_pools_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'cannot create a pool' do
          expect { post v1_pacbio_pools_path, params: body, headers: json_api_headers }.not_to(
            change(Pacbio::Pool, :count)
          )
        end
      end

      context 'on failure - when there is aliquot id thats not part of the pool' do
        let(:additional_aliquot) { create(:aliquot) }
        let(:body) do
          {
            data: {
              type: 'pools',
              attributes: {
                used_aliquots_attributes: [
                  {
                    id: additional_aliquot.id.to_s,
                    template_prep_kit_box_barcode: 'LK1234567',
                    volume: 1.11,
                    concentration: 2.22,
                    insert_size: 100,
                    source_id: request.id,
                    source_type: 'Pacbio::Request',
                    tag_id: tag.id
                  },
                  {
                    template_prep_kit_box_barcode: 'LK1234567',
                    volume: 1.11,
                    concentration: 2.22,
                    insert_size: 100,
                    source_id: request.id,
                    source_type: 'Pacbio::Request',
                    tag_id: tag2.id
                  }
                ],
                primary_aliquot_attributes: {
                  volume: '200',
                  concentration: '22',
                  template_prep_kit_box_barcode: '100',
                  insert_size: '11'
                }
              }
            }
          }.to_json
        end

        it 'returns internal_server_error status' do
          post v1_pacbio_pools_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:internal_server_error)
          expect(response.body).to include('Library is not part of the pool')
        end

        it 'cannot create a pool' do
          expect { post v1_pacbio_pools_path, params: body, headers: json_api_headers }.not_to(
            change(Pacbio::Pool, :count)
          )
        end
      end
    end
  end

  describe '#updating via libraries' do
    context 'when updating a multiplex library' do
      let!(:pool) { create(:pacbio_pool, library_count: 2) }
      # We let! this as we want to ensure we have the original state
      let!(:updated_library) { pool.libraries.first }
      let!(:removed_library) { pool.libraries.last }
      let(:added_request) { create(:pacbio_request) }

      before do
        patch v1_pacbio_pool_path(pool), params: body, headers: json_api_headers
      end

      context 'on success' do
        let(:body) do
          {
            data: {
              type: 'pools',
              id: pool.id.to_s,
              attributes: {
                library_attributes: [
                  {
                    id: updated_library.id.to_s,
                    pacbio_request_id: updated_library.pacbio_request_id.to_s,
                    template_prep_kit_box_barcode: 'LK12345',
                    tag_id: tag.id,
                    volume: 1,
                    concentration: 1,
                    insert_size: 100
                  },
                  {
                    pacbio_request_id: added_request.id.to_s,
                    template_prep_kit_box_barcode: 'LK12345',
                    tag_id: tag2.id,
                    volume: 1,
                    concentration: 1,
                    insert_size: 100
                  }
                ],
                volume: '200',
                concentration: '22',
                template_prep_kit_box_barcode: '100',
                insert_size: '11',
                created_at: '2021-08-04T14:35:47.208Z',
                updated_at: '2021-08-04T14:35:47.208Z'
              }
            }
          }.to_json
        end

        it 'returns created status' do
          expect(response).to have_http_status(:success), response.body
        end

        it 'updates a pool' do
          pool.reload
          expect(pool.template_prep_kit_box_barcode).to eq('100')
        end

        it 'updates libraries accordingly' do
          # Adds new libraries
          pool.reload
          expect(pool.libraries.length).to eq(2)
          expect(pool.libraries.collect(&:pacbio_request_id)).to include(added_request.id)

          # Updates the existing library
          updated_library.reload
          expect(updated_library.template_prep_kit_box_barcode).to eq('LK12345')

          # Destroys the removed library
          expect(Pacbio::Library.find_by(pacbio_request_id: removed_library.pacbio_request_id)).to be_nil
        end

        it 'updates used_aliquots accordingly' do
          # Adds new aliquots
          pool.reload
          expect(pool.used_aliquots.length).to eq(2)
          expect(pool.used_aliquots.collect(&:source_id)).to include(added_request.id)

          # Updates the existing aliquot
          updated_aliquot = pool.used_aliquots.find_by(source_id: updated_library.pacbio_request_id)
          expect(updated_aliquot.template_prep_kit_box_barcode).to eq('LK12345')

          # Destroys the removed aliquot
          expect(Aliquot.find_by(source_id: removed_library.pacbio_request_id, used_by: pool)).to be_nil
        end
      end

      context 'on failure - when there is a tag clash' do
        let(:body) do
          {
            data: {
              type: 'pools',
              id: pool.id.to_s,
              attributes: {
                library_attributes: [
                  {
                    id: updated_library.id.to_s,
                    pacbio_request_id: updated_library.pacbio_request_id.to_s,
                    template_prep_kit_box_barcode: 'LK12345',
                    tag_id: tag.id,
                    volume: 1,
                    concentration: 1,
                    insert_size: 100
                  },
                  {
                    pacbio_request_id: added_request.id.to_s,
                    template_prep_kit_box_barcode: 'LK12345',
                    tag_id: tag.id,
                    volume: 1,
                    concentration: 1,
                    insert_size: 100
                  }
                ],
                volume: '200',
                concentration: '22',
                template_prep_kit_box_barcode: '100',
                insert_size: '11',
                created_at: '2021-08-04T14:35:47.208Z',
                updated_at: '2021-08-04T14:35:47.208Z'
              }
            }
          }.to_json
        end

        it 'returns unprocessable entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not update a pool' do
          pool.reload
          expect(pool.template_prep_kit_box_barcode).not_to eq('100')
        end

        it 'does not change the libraries' do
          attributes = pool.libraries.reload.map(&:attributes)
          expect(attributes).to include(updated_library.attributes)
          expect(attributes).to include(removed_library.attributes)
        end

        it 'does not change the used aliquots' do
          attributes = pool.used_aliquots.reload.map(&:attributes)
          updated_aliquot = pool.used_aliquots.find_by(source_id: updated_library.pacbio_request_id)
          removed_aliquot = pool.used_aliquots.find_by(source_id: removed_library.pacbio_request_id)
          expect(attributes).to include(updated_aliquot.attributes)
          expect(attributes).to include(removed_aliquot.attributes)
        end
      end
    end

    context 'when there is an associated run' do
      let!(:pool) { create(:pacbio_pool) }
      let!(:updated_library) { pool.libraries.first }
      let!(:plate) { build(:pacbio_plate) }
      let(:run) { create(:pacbio_run, plates: [plate]) }

      let(:body) do
        {
          data: {
            type: 'pools',
            id: pool.id.to_s,
            attributes: {
              library_attributes: [
                {
                  id: updated_library.id.to_s,
                  pacbio_request_id: updated_library.pacbio_request_id.to_s,
                  template_prep_kit_box_barcode: 'LK12345',
                  tag_id: tag.id,
                  volume: 1,
                  concentration: 1,
                  insert_size: 100
                }
              ],
              volume: '200',
              concentration: '22',
              template_prep_kit_box_barcode: '100',
              insert_size: '11',
              created_at: '2021-08-04T14:35:47.208Z',
              updated_at: '2021-08-04T14:35:47.208Z'
            }
          }
        }.to_json
      end

      before { create(:pacbio_well, pools: [pool], plate:) }

      it 'publishes a message' do
        expect(Messages).to receive(:publish).with(pool.sequencing_runs, having_attributes(pipeline: 'pacbio'))
        patch v1_pacbio_pool_path(pool), params: body, headers: json_api_headers
        expect(response).to have_http_status(:success), response.body
      end
    end
  end

  describe '#updating via aliquots' do
    before do
      Flipper.enable(:multiplexing_phase_2_aliquot)
    end

    context 'when updating a multiplex pool' do
      let!(:pool) { create(:pacbio_pool, library_count: 2) }
      # We let! this as we want to ensure we have the original state
      let!(:updated_aliquot) { pool.used_aliquots.first }
      let!(:removed_aliquot) { pool.used_aliquots.last }
      let!(:primary_aliquot) { pool.primary_aliquot }
      let(:added_request) { create(:pacbio_request) }

      before do
        patch v1_pacbio_pool_path(pool), params: body, headers: json_api_headers
      end

      context 'on success' do
        let(:body) do
          {
            data: {
              type: 'pools',
              id: pool.id.to_s,
              attributes: {
                used_aliquots_attributes: [
                  {
                    id: updated_aliquot.id.to_s,
                    source_id: updated_aliquot.source.id.to_s,
                    source_type: 'Pacbio::Request',
                    template_prep_kit_box_barcode: 'LK12345',
                    tag_id: tag.id,
                    volume: 1,
                    concentration: 1,
                    insert_size: 100
                  },
                  {
                    source_id: added_request.id.to_s,
                    source_type: 'Pacbio::Request',
                    template_prep_kit_box_barcode: 'LK12345',
                    tag_id: tag2.id,
                    volume: 1,
                    concentration: 1,
                    insert_size: 100
                  }
                ],
                primary_aliquot_attributes: {
                  id: pool.primary_aliquot.id.to_s,
                  volume: '200',
                  concentration: '22',
                  template_prep_kit_box_barcode: '100',
                  insert_size: '11'
                },
                volume: '200',
                concentration: '22',
                template_prep_kit_box_barcode: '100',
                insert_size: '11',
                created_at: '2021-08-04T14:35:47.208Z',
                updated_at: '2021-08-04T14:35:47.208Z'
              }
            }
          }.to_json
        end

        it 'returns created status' do
          expect(response).to have_http_status(:success), response.body
        end

        it 'updates a pool' do
          pool.reload
          expect(pool.template_prep_kit_box_barcode).to eq('100')
        end

        it 'updates the primary aliquot' do
          pool.reload
          expect(pool.primary_aliquot.template_prep_kit_box_barcode).to eq('100')
        end

        it 'updates used_aliquots accordingly' do
          # Adds new aliquots
          pool.reload
          expect(pool.used_aliquots.length).to eq(2)
          expect(pool.used_aliquots.collect(&:source_id)).to include(added_request.id)

          # Updates the existing aliquot
          updated_aliquot.reload
          expect(updated_aliquot.template_prep_kit_box_barcode).to eq('LK12345')

          # Destroys the removed aliquot
          expect(Aliquot.find_by(id: removed_aliquot.id, used_by: pool)).to be_nil
        end

        it 'updates the libraries accordingly' do
          # Adds new libraries
          pool.reload
          expect(pool.libraries.length).to eq(2)
          expect(pool.libraries.collect(&:pacbio_request_id)).to include(added_request.id)

          # Updates the existing library
          updated_library = pool.libraries.find_by(pacbio_request_id: updated_aliquot.source_id)
          expect(updated_library.template_prep_kit_box_barcode).to eq('LK12345')

          # Destroys the removed library
          expect(Pacbio::Library.find_by(pacbio_request_id: removed_aliquot.source_id)).to be_nil
        end
      end

      context 'on failure - when there is a tag clash' do
        let(:body) do
          {
            data: {
              type: 'pools',
              id: pool.id.to_s,
              attributes: {
                used_aliquots_attributes: [
                  {
                    id: updated_aliquot.id.to_s,
                    source_id: updated_aliquot.source.id.to_s,
                    source_type: 'Pacbio::Request',
                    template_prep_kit_box_barcode: 'LK12345',
                    tag_id: tag.id,
                    volume: 1,
                    concentration: 1,
                    insert_size: 100
                  },
                  {
                    source_id: added_request.id.to_s,
                    source_type: 'Pacbio::Request',
                    template_prep_kit_box_barcode: 'LK12345',
                    tag_id: tag.id,
                    volume: 1,
                    concentration: 1,
                    insert_size: 100
                  }
                ],
                volume: '200',
                concentration: '22',
                template_prep_kit_box_barcode: '100',
                insert_size: '11',
                created_at: '2021-08-04T14:35:47.208Z',
                updated_at: '2021-08-04T14:35:47.208Z'
              }
            }
          }.to_json
        end

        it 'returns unprocessable entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not update a pool' do
          pool.reload
          expect(pool.template_prep_kit_box_barcode).not_to eq('100')
        end

        it 'does not change the aliquots' do
          primary_aliquot_attributes = pool.primary_aliquot.reload.attributes
          expect(primary_aliquot_attributes).to include(primary_aliquot.attributes)

          used_aliquots_attributes = pool.used_aliquots.reload.map(&:attributes)
          expect(used_aliquots_attributes).to include(updated_aliquot.attributes)
          expect(used_aliquots_attributes).to include(removed_aliquot.attributes)
        end

        it 'does not change the libraries' do
          attributes = pool.libraries.reload.map(&:attributes)
          updated_library = pool.libraries.find_by(pacbio_request_id: updated_aliquot.source_id)
          removed_library = pool.libraries.find_by(pacbio_request_id: removed_aliquot.source_id)
          expect(attributes).to include(updated_library.attributes)
          expect(attributes).to include(removed_library.attributes)
        end
      end
    end

    context 'when there is an associated run' do
      let!(:pool) { create(:pacbio_pool) }
      let!(:updated_aliquot) { pool.used_aliquots.first }
      let!(:plate) { build(:pacbio_plate) }
      let(:run) { create(:pacbio_run, plates: [plate]) }

      let(:body) do
        {
          data: {
            type: 'pools',
            id: pool.id.to_s,
            attributes: {
              used_aliquots_attributes: [
                {
                  id: updated_aliquot.id.to_s,
                  source_id: updated_aliquot.source.id.to_s,
                  source_type: 'Pacbio::Request',
                  template_prep_kit_box_barcode: 'LK12345',
                  tag_id: tag.id,
                  volume: 1,
                  concentration: 1,
                  insert_size: 100
                }
              ],
              volume: '200',
              concentration: '22',
              template_prep_kit_box_barcode: '100',
              insert_size: '11',
              created_at: '2021-08-04T14:35:47.208Z',
              updated_at: '2021-08-04T14:35:47.208Z'
            }
          }
        }.to_json
      end

      before { create(:pacbio_well, pools: [pool], plate:) }

      it 'publishes a message' do
        expect(Messages).to receive(:publish).with(pool.sequencing_runs, having_attributes(pipeline: 'pacbio'))
        patch v1_pacbio_pool_path(pool), params: body, headers: json_api_headers
        expect(response).to have_http_status(:success), response.body
      end
    end
  end
end
