# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PoolsController', type: :request, pacbio: true do
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

    it 'returns pool attributes', aggregate_failures: true do
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

    it 'returns the correct attributes', aggregate_failures: true do
      get "#{v1_pacbio_pools_path}?include=libraries", headers: json_api_headers

      expect(response).to have_http_status(:success)

      library_attributes = json['included'][0]['attributes']
      library = pools.first.libraries.first

      expect(library_attributes['volume']).to eq(library.volume)
      expect(library_attributes['concentration']).to eq(library.concentration)
      expect(library_attributes['template_prep_kit_box_barcode']).to eq(library.template_prep_kit_box_barcode)
      expect(library_attributes['insert_size']).to eq(library.insert_size)
    end
  end

  describe '#create' do
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
                ]
              }
            }
          }.to_json
        end

        it 'has a created status' do
          post v1_pacbio_pools_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created), response.body
        end

        it 'creates a pool' do
          expect { post v1_pacbio_pools_path, params: body, headers: json_api_headers }.to change {
                                                                                             Pacbio::Pool.count
                                                                                           }.by(1)
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

      context 'on failure' do
        context 'when library is invalid' do
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
                  ]
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
                ]
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
            change(Pacbio::Pool, :count).by(1)
          )
        end
      end

      context 'on failure' do
        context 'when there is a tag clash' do
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
                  ]
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
    end
  end

  describe '#updating' do
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

        it 'update libraries' do
          updated_library.reload
          expect(updated_library.template_prep_kit_box_barcode).to eq('LK12345')
        end

        it 'destroys removed libraries' do
          expect(Pacbio::Library.find_by(id: removed_library)).to be_nil
        end

        it 'adds new libraries' do
          libraries = pool.libraries.reload
          new_libraries = libraries.reject do |library|
            [updated_library.id, removed_library.id].include?(library.id)
          end
          expect(new_libraries.length).to eq(1)
          expect(new_libraries.first.pacbio_request_id).to eq(added_request.id)
        end
      end

      context 'on failure' do
        context 'when there is a tag clash' do
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
        end
      end
    end

    context 'when there is an associated run' do
      let!(:pool) { create(:pacbio_pool) }
      let!(:updated_library) { pool.libraries.first }
      let!(:plate) { create(:pacbio_plate) }
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

      before { create(:pacbio_well, pools: [pool], plate: plate) }

      it 'publishes a message' do
        expect(Messages).to receive(:publish).with(pool.sequencing_plates,
                                                   having_attributes(pipeline: 'pacbio'))
        patch v1_pacbio_pool_path(pool), params: body, headers: json_api_headers
        expect(response).to have_http_status(:success), response.body
      end
    end
  end
end
