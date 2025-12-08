# frozen_string_literal: true

require 'rails_helper'

# Note (updating/creating multi pools):
# The validation for pools is handled in the nested pool models and their
# resources. Here we are primarily testing the MultiPool and MultiPoolResource
# functionality with a few important validation cases.
RSpec.describe 'MultiPoolsController' do
  before do
    # Create a default smrt link version for pacbio runs.
    # We use when checking validation behaviour later
    create(:pacbio_smrt_link_version_default)
  end

  describe '#get' do
    let!(:multi_pool1) { create(:multi_pool) }
    let!(:multi_pool2) { create(:multi_pool) }

    it 'returns a list of multi pools' do
      get v1_multi_pools_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
      expect(json['data'][0]['attributes']['pool_method']).to eq(multi_pool1.pool_method)
      expect(json['data'][0]['attributes']['pipeline']).to eq(multi_pool1.pipeline)
      expect(json['data'][0]['attributes']['number_of_pools']).to eq(multi_pool1.multi_pool_positions.count)
      expect(json['data'][0]['attributes']['created_at']).to eq(multi_pool1.created_at.to_fs(:us))

      expect(json['data'][1]['attributes']['pool_method']).to eq(multi_pool2.pool_method)
      expect(json['data'][1]['attributes']['pipeline']).to eq(multi_pool2.pipeline)
      expect(json['data'][0]['attributes']['number_of_pools']).to eq(multi_pool1.multi_pool_positions.count)
      expect(json['data'][1]['attributes']['created_at']).to eq(multi_pool2.created_at.to_fs(:us))
    end

    describe 'with includes' do
      describe 'pacbio data' do
        let!(:multi_pools) { create_list(:multi_pool, 5) }
        let(:multi_pool_relationships) do
          multi_pool_resource = find_resource(type: 'multi_pools', id: multi_pools.first.id)
          multi_pool_resource.fetch('relationships')
        end
        let(:multi_pool) { multi_pools.first }

        before do
          get "#{v1_multi_pools_path}?include=multi_pool_positions.pacbio_pool",
              headers: json_api_headers
        end

        it 'has a success status' do
          expect(response).to have_http_status(:success)
        end

        it 'returns the correct relationships and included data', :aggregate_failures do
          multi_pool_position = multi_pool.multi_pool_positions.first
          pacbio_pool = multi_pool_position.pool
          multi_pool_positions_relationship = multi_pool_relationships.dig('multi_pool_positions', 'data')
          expect(multi_pool_positions_relationship[0]['id']).to eq(multi_pool_position.id.to_s)
          expect(multi_pool_positions_relationship[0]['type']).to eq('multi_pool_positions')

          multi_pool_position_resource = find_included_resource(type: 'multi_pool_positions', id: multi_pool_position.id)
          expect(multi_pool_position_resource.dig('attributes', 'position')).to eq(multi_pool_position.position)
          expect(multi_pool_position_resource.dig('relationships', 'pacbio_pool', 'data', 'id')).to eq(pacbio_pool.id.to_s)
          expect(multi_pool_position_resource.dig('relationships', 'pacbio_pool', 'data', 'type')).to eq('pools')

          pacbio_pool_resource = find_included_resource(type: 'pools', id: pacbio_pool.id)
          expect(pacbio_pool_resource.dig('attributes', 'volume')).to eq(pacbio_pool.volume)
        end
      end
    end

    context 'pagination' do
      let!(:expected_multi_pools) { create_list(:multi_pool, 2, created_at: Time.zone.now) }

      before do
        create_list(:multi_pool, 2, created_at: Time.zone.now + 10)
        # There should be 4 pools total so we should expect the oldest 2 on page 2
        get "#{v1_multi_pools_path}?page[number]=2&page[size]=2",
            headers: json_api_headers
      end

      it 'has a success status' do
        expect(response).to have_http_status(:success), response.body
      end

      it 'returns a list of multi_pools' do
        expect(json['data'].length).to eq(2)
      end

      it 'returns the correct attributes', :aggregate_failures do
        expected_multi_pools.each do |mp|
          mp_attributes = find_resource(type: 'multi_pools', id: mp.id)['attributes']
          expect(mp_attributes).to include(
            'pool_method' => mp.pool_method,
            'pipeline' => mp.pipeline,
            'number_of_pools' => mp.number_of_pools,
            'created_at' => mp.created_at.to_fs(:us)
          )
        end
      end
    end

    describe 'filters' do
      describe 'by pipeline' do
        it 'returns the correct multi pools for the given pipeline', :aggregate_failures do
          # ont_multi_pools
          create_list(:multi_pool, 5, pipeline: 'ont')
          pacbio_multi_pool = create(:multi_pool, pipeline: 'pacbio')
          pipeline = 'pacbio'
          get "#{v1_multi_pools_path}?filter[pipeline]=#{pipeline}", headers: json_api_headers

          expect(response).to have_http_status(:success)
          expect(json['data'].length).to eq(1)
          multi_pool_attributes = find_resource(type: 'multi_pools', id: pacbio_multi_pool.id)['attributes']
          expect(multi_pool_attributes).to include(
            'pipeline' => pacbio_multi_pool.pipeline,
            'pool_method' => pacbio_multi_pool.pool_method,
            'number_of_pools' => pacbio_multi_pool.number_of_pools,
            'created_at' => pacbio_multi_pool.created_at.to_fs(:us)
          )
        end

        it 'returns no multi pools if no multi pools from that pipeline exist' do
          create_list(:multi_pool, 5, pipeline: 'ont')
          pipeline = 'saphyr'
          get "#{v1_multi_pools_path}?filter[pipeline]=#{pipeline}", headers: json_api_headers

          expect(response).to have_http_status(:success)
          expect(json['data'].length).to eq(0)
        end
      end

      describe 'by pool_method' do
        it 'returns the correct multi pools for the given pool_method', :aggregate_failures do
          create_list(:multi_pool, 5, pool_method: 'Plate')
          tube_rack_multi_pool = create(:multi_pool, pool_method: 'TubeRack')
          pool_method = 'TubeRack'
          get "#{v1_multi_pools_path}?filter[pool_method]=#{pool_method}", headers: json_api_headers

          expect(response).to have_http_status(:success)
          expect(json['data'].length).to eq(1)
          multi_pool_attributes = find_resource(type: 'multi_pools', id: tube_rack_multi_pool.id)['attributes']
          expect(multi_pool_attributes).to include(
            'pipeline' => tube_rack_multi_pool.pipeline,
            'pool_method' => tube_rack_multi_pool.pool_method,
            'number_of_pools' => tube_rack_multi_pool.number_of_pools,
            'created_at' => tube_rack_multi_pool.created_at.to_fs(:us)
          )
        end

        it 'returns no multi pools if no multi pools from that pool_method exist' do
          create_list(:multi_pool, 5, pool_method: 'Plate')
          pool_method = 'TubeRack'
          get "#{v1_multi_pools_path}?filter[pool_method]=#{pool_method}", headers: json_api_headers

          expect(response).to have_http_status(:success)
          expect(json['data'].length).to eq(0)
        end
      end

      describe 'by pool_barcode' do
        it 'returns the correct multi pools containing pools with the given pacbio pool_barcode', :aggregate_failures do
          mps = create_list(:multi_pool, 5)
          expected_multi_pool = mps.first
          pool_barcode = expected_multi_pool.multi_pool_positions.first.pacbio_pool.tube.barcode
          get "#{v1_multi_pools_path}?filter[pool_barcode]=#{pool_barcode}", headers: json_api_headers

          expect(response).to have_http_status(:success)
          expect(json['data'].length).to eq(1)
          multi_pool_attributes = find_resource(type: 'multi_pools', id: expected_multi_pool.id)['attributes']
          expect(multi_pool_attributes).to include(
            'pipeline' => expected_multi_pool.pipeline,
            'pool_method' => expected_multi_pool.pool_method,
            'number_of_pools' => expected_multi_pool.number_of_pools,
            'created_at' => expected_multi_pool.created_at.to_fs(:us)
          )
        end

        it 'returns the correct multi pools containing pools with the given ont pool_barcode', :aggregate_failures do
          mps = create_list(:multi_pool, 5)
          expected_multi_pool = mps.first
          expected_multi_pool.multi_pool_positions = build_list(:multi_pool_position, 1, pool: create(:ont_pool, barcode: 'TRAC-2-12345'))
          pool_barcode = 'TRAC-2-12345'
          get "#{v1_multi_pools_path}?filter[pool_barcode]=#{pool_barcode}", headers: json_api_headers

          expect(response).to have_http_status(:success)
          expect(json['data'].length).to eq(1)
          multi_pool_attributes = find_resource(type: 'multi_pools', id: expected_multi_pool.id)['attributes']
          expect(multi_pool_attributes).to include(
            'pipeline' => expected_multi_pool.pipeline,
            'pool_method' => expected_multi_pool.pool_method,
            'number_of_pools' => expected_multi_pool.number_of_pools,
            'created_at' => expected_multi_pool.created_at.to_fs(:us)
          )
        end

        it 'returns no multi pools if no multi pools containing pools with the given pool_barcode exist' do
          create_list(:multi_pool, 5)
          pool_barcode = 'RandomPoolBarcode'
          get "#{v1_multi_pools_path}?filter[pool_barcode]=#{pool_barcode}", headers: json_api_headers

          expect(response).to have_http_status(:success)
          expect(json['data'].length).to eq(0)
        end
      end
    end
  end

  describe '#create' do
    context 'successful' do
      context 'when creating a multi pool with several valid pools' do
        let!(:request) { create(:pacbio_request) }
        let!(:tag) { create(:tag) }
        let(:body) do
          {
            data: {
              type: 'multi_pools',
              attributes: {
                pipeline: 'pacbio',
                pool_method: 'Plate',
                multi_pool_positions_attributes: [
                  {
                    position: 'A1',
                    pacbio_pool_attributes: {
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
                  },
                  {
                    position: 'A2',
                    pacbio_pool_attributes: {
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
                ]
              }
            }
          }.to_json
        end

        it 'has a created status' do
          post v1_multi_pools_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created), response.body
        end

        it 'creates a multi pool and associated data' do
          expect { post v1_multi_pools_path, params: body, headers: json_api_headers }.to change(MultiPool, :count).by(1).and change(MultiPoolPosition, :count).by(2).and change(Pacbio::Pool, :count).by(2)
        end

        it 'returns the id' do
          post v1_multi_pools_path, params: body, headers: json_api_headers
          expect(json.dig('data', 'id').to_i).to eq(MultiPool.first.id)
        end
      end
    end

    context 'unsuccessful' do
      context 'when creating a multi pool with bad data' do
        let(:body) do
          {
            data: {
              type: 'multi_pools',
              attributes: {
                pipeline: 'pacbio',
                pool_method: 'InvalidMethod'
              }
            }
          }.to_json
        end

        it 'has a bad_request status' do
          post v1_multi_pools_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:bad_request), response.body
        end

        it 'does not create a multi pool or associated data' do
          expect { post v1_multi_pools_path, params: body, headers: json_api_headers }.not_to change(MultiPool, :count)
        end

        it 'returns the correct error messages' do
          post v1_multi_pools_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['errors']
          expect(errors[0]['detail']).to eq 'InvalidMethod is not a valid value for pool_method.'
        end
      end

      context 'when creating a multi pool with invalid multi pool positions (duplicate positions)' do
        let!(:request) { create(:pacbio_request) }
        let!(:tag) { create(:tag) }
        let(:body) do
          {
            data: {
              type: 'multi_pools',
              attributes: {
                pipeline: 'pacbio',
                pool_method: 'Plate',
                multi_pool_positions_attributes: [
                  {
                    position: 'A1',
                    pacbio_pool_attributes: {
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
                  },
                  {
                    position: 'A1',
                    pacbio_pool_attributes: {
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
                ]
              }
            }
          }.to_json
        end

        it 'has a unprocessable_content status' do
          post v1_multi_pools_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_content), response.body
        end

        it 'does not create a multi pool or associated data' do
          expect { post v1_multi_pools_path, params: body, headers: json_api_headers }.not_to change(MultiPool, :count)
        end

        it 'returns the correct error messages' do
          post v1_multi_pools_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['errors']
          expect(errors[0]['detail']).to eq 'multi_pool_positions - A1 positions are duplicated'
        end
      end

      context 'when creating a multi pool with invalid pool data (duplicate tags)' do
        let!(:request) { create(:pacbio_request) }
        let!(:tag) { create(:tag) }
        let(:body) do
          {
            data: {
              type: 'multi_pools',
              attributes: {
                pipeline: 'pacbio',
                pool_method: 'Plate',
                multi_pool_positions_attributes: [
                  {
                    position: 'A1',
                    pacbio_pool_attributes: {
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
                        },
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
                ]
              }
            }
          }.to_json
        end

        it 'has a unprocessable_content status' do
          post v1_multi_pools_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_content), response.body
        end

        it 'does not create a multi pool or associated data' do
          expect { post v1_multi_pools_path, params: body, headers: json_api_headers }.not_to change(MultiPool, :count)
        end

        it 'returns the correct error messages' do
          post v1_multi_pools_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['errors']
          expect(errors[0]['detail']).to eq 'multi_pool_positions.pacbio_pool.tags - contain duplicates'
        end
      end
    end
  end

  describe '#update' do
    context 'on success' do
      # We let! this as we want to ensure we have the original state
      let!(:mp) do
        mp = create(:multi_pool, pool_method: 'Plate')
        # Ensure the existing pool has position A1
        mp.multi_pool_positions.first.position = 'A1'
        mp
      end
      let!(:existing_pool) { mp.multi_pool_positions.first.pacbio_pool }

      before do
        patch v1_multi_pool_path(mp), params: body, headers: json_api_headers
      end

      context 'when updating a multi pool (adding a pool and updating pool attributes)' do
        let(:new_pool_volume) { 101.0 }
        let(:body) do
          {
            data: {
              id: mp.id.to_s,
              type: 'multi_pools',
              attributes: {
                pipeline: 'pacbio',
                pool_method: 'TubeRack',
                multi_pool_positions_attributes: [
                  {
                    id: mp.multi_pool_positions.first.id.to_s,
                    position: mp.multi_pool_positions.first.position,
                    pacbio_pool_attributes: {
                      id: existing_pool.id.to_s,
                      used_aliquots_attributes: [{
                        id: existing_pool.used_aliquots.first.id.to_s,
                        volume: existing_pool.used_aliquots.first.volume,
                        concentration: existing_pool.used_aliquots.first.concentration,
                        template_prep_kit_box_barcode: existing_pool.used_aliquots.first.template_prep_kit_box_barcode,
                        insert_size: existing_pool.used_aliquots.first.insert_size,
                        source_id: existing_pool.used_aliquots.first.source_id,
                        source_type: existing_pool.used_aliquots.first.source_type
                      }],
                      primary_aliquot_attributes: {
                        id: existing_pool.primary_aliquot.id.to_s,
                        volume: new_pool_volume,
                        concentration: existing_pool.primary_aliquot.concentration,
                        template_prep_kit_box_barcode: existing_pool.primary_aliquot.template_prep_kit_box_barcode,
                        insert_size: existing_pool.primary_aliquot.insert_size
                      },
                      volume: new_pool_volume,
                      concentration: existing_pool.concentration,
                      template_prep_kit_box_barcode: existing_pool.template_prep_kit_box_barcode,
                      insert_size: existing_pool.insert_size,
                      created_at: '2021-08-04T14:35:47.208Z',
                      updated_at: '2021-08-04T14:35:47.208Z'
                    }
                  },
                  {
                    position: 'A2',
                    pacbio_pool_attributes: {
                      volume: '150',
                      concentration: '15',
                      template_prep_kit_box_barcode: '100',
                      insert_size: '100',
                      used_aliquots_attributes: [{
                        volume: '150',
                        concentration: '15',
                        template_prep_kit_box_barcode: '200',
                        insert_size: '20',
                        source_id: create(:pacbio_request).id,
                        source_type: 'Pacbio::Request',
                        tag_id: create(:tag).id
                      }],
                      primary_aliquot_attributes: {
                        volume: '150',
                        concentration: '15',
                        template_prep_kit_box_barcode: '200',
                        insert_size: '20'
                      }
                    }
                  }
                ]
              }
            }
          }.to_json
        end

        it 'returns created status' do
          expect(response).to have_http_status(:success), response.body
        end

        it 'updates the multi_pool' do
          mp.reload
          expect(mp.pool_method).to eq('TubeRack')
          expect(mp.number_of_pools).to eq(2)
        end

        it 'updates the existing pool' do
          existing_pool.reload
          expect(existing_pool.volume).to eq(new_pool_volume)
          expect(existing_pool.primary_aliquot.volume).to eq(new_pool_volume)
        end

        it 'creates a new pool' do
          # Check the existing pool is unchanged
          expect(existing_pool).to eq(mp.multi_pool_positions.find_by(position: 'A1').pacbio_pool)

          # Check the new pool exists and has some of the correct attributes
          new_pool = mp.multi_pool_positions.find_by(position: 'A2').pacbio_pool
          expect(new_pool.volume).to eq(150.0)
        end
      end

      context 'when updating a multi pool (removing a pool)' do
        let(:position_to_destroy) { build(:multi_pool_position, position: 'A2', pool: create(:pacbio_pool)) }
        let(:pool_to_destroy) { position_to_destroy.pool }
        let!(:mp) do
          mp = create(:multi_pool)
          # Ensure the existing pool has position A1
          mp.multi_pool_positions.first.position = 'A1'
          # Create a second existing pool to remove
          mp.multi_pool_positions << position_to_destroy
          mp
        end
        let!(:existing_pool) { mp.multi_pool_positions.first.pacbio_pool }
        let(:body) do
          {
            data: {
              id: mp.id.to_s,
              type: 'multi_pools',
              attributes: {
                pipeline: 'pacbio',
                pool_method: 'Plate',
                multi_pool_positions_attributes: [
                  {
                    id: mp.multi_pool_positions.first.id.to_s,
                    position: mp.multi_pool_positions.first.position,
                    pacbio_pool_attributes: {
                      id: existing_pool.id.to_s,
                      used_aliquots_attributes: [{
                        id: existing_pool.used_aliquots.first.id.to_s,
                        volume: existing_pool.used_aliquots.first.volume,
                        concentration: existing_pool.used_aliquots.first.concentration,
                        template_prep_kit_box_barcode: existing_pool.used_aliquots.first.template_prep_kit_box_barcode,
                        insert_size: existing_pool.used_aliquots.first.insert_size,
                        source_id: existing_pool.used_aliquots.first.source_id,
                        source_type: existing_pool.used_aliquots.first.source_type
                      }],
                      primary_aliquot_attributes: {
                        id: existing_pool.primary_aliquot.id.to_s,
                        volume: existing_pool.primary_aliquot.volume,
                        concentration: existing_pool.primary_aliquot.concentration,
                        template_prep_kit_box_barcode: existing_pool.primary_aliquot.template_prep_kit_box_barcode,
                        insert_size: existing_pool.primary_aliquot.insert_size
                      },
                      volume: existing_pool.volume,
                      concentration: existing_pool.concentration,
                      template_prep_kit_box_barcode: existing_pool.template_prep_kit_box_barcode,
                      insert_size: existing_pool.insert_size,
                      created_at: '2021-08-04T14:35:47.208Z',
                      updated_at: '2021-08-04T14:35:47.208Z'
                    }
                  },
                  {
                    id: position_to_destroy.id.to_s,
                    _destroy: true
                  }
                ]
              }
            }
          }.to_json
        end

        it 'returns created status' do
          expect(response).to have_http_status(:success), response.body
        end

        it 'updates the multi_pool' do
          mp.reload
          expect(mp.number_of_pools).to eq(1)
        end

        it 'destroys the existing pool position and pool' do
          expect { MultiPoolPosition.find(position_to_destroy.id) }.to raise_error(ActiveRecord::RecordNotFound)
          expect { Pacbio::Pool.find(pool_to_destroy.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'on failure' do
      # We let! this as we want to ensure we have the original state
      let!(:mp) do
        mp = create(:multi_pool, pool_method: 'Plate')
        # Ensure the existing pool has position A1
        mp.multi_pool_positions.first.position = 'A1'
        mp
      end
      let!(:existing_pool) { mp.multi_pool_positions.first.pacbio_pool }

      before do
        patch v1_multi_pool_path(mp), params: body, headers: json_api_headers
      end

      context 'when updating a multi pool (invalid multi_pool data)' do
        let(:new_pool_volume) { 101.0 }
        let(:body) do
          {
            data: {
              id: mp.id.to_s,
              type: 'multi_pools',
              attributes: {
                pipeline: 'pacbio',
                pool_method: 'InvalidMethod'

              }
            }
          }.to_json
        end

        it 'has a bad_request status' do
          expect(response).to have_http_status(:bad_request), response.body
        end

        it 'does not update the multi pool or associated data' do
          mp.reload
          expect(mp.pool_method).to eq('Plate')
        end

        it 'returns the correct error messages' do
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['errors']
          expect(errors[0]['detail']).to eq 'InvalidMethod is not a valid value for pool_method.'
        end
      end

      context 'when updating a multi pool (with a tag clash)' do
        let(:new_pool_volume) { 101.0 }
        let(:body) do
          {
            data: {
              id: mp.id.to_s,
              type: 'multi_pools',
              attributes: {
                pipeline: 'pacbio',
                pool_method: 'Plate',
                multi_pool_positions_attributes: [
                  {
                    id: mp.multi_pool_positions.first.id.to_s,
                    position: mp.multi_pool_positions.first.position,
                    pacbio_pool_attributes: {
                      id: existing_pool.id.to_s,
                      used_aliquots_attributes: [
                        {
                          id: existing_pool.used_aliquots.first.id.to_s,
                          volume: existing_pool.used_aliquots.first.volume,
                          concentration: existing_pool.used_aliquots.first.concentration,
                          template_prep_kit_box_barcode: existing_pool.used_aliquots.first.template_prep_kit_box_barcode,
                          insert_size: existing_pool.used_aliquots.first.insert_size,
                          source_id: existing_pool.used_aliquots.first.source_id,
                          source_type: existing_pool.used_aliquots.first.source_type,
                          tag_id: existing_pool.used_aliquots.first.tag_id
                        },
                        {
                          volume: existing_pool.used_aliquots.first.volume,
                          concentration: existing_pool.used_aliquots.first.concentration,
                          template_prep_kit_box_barcode: existing_pool.used_aliquots.first.template_prep_kit_box_barcode,
                          insert_size: existing_pool.used_aliquots.first.insert_size,
                          source_id: existing_pool.used_aliquots.first.source_id,
                          source_type: existing_pool.used_aliquots.first.source_type,
                          tag_id: existing_pool.used_aliquots.first.tag_id
                        }
                      ],
                      primary_aliquot_attributes: {
                        id: existing_pool.primary_aliquot.id.to_s,
                        volume: existing_pool.primary_aliquot.volume,
                        concentration: existing_pool.primary_aliquot.concentration,
                        template_prep_kit_box_barcode: existing_pool.primary_aliquot.template_prep_kit_box_barcode,
                        insert_size: existing_pool.primary_aliquot.insert_size
                      },
                      volume: existing_pool.volume,
                      concentration: existing_pool.concentration,
                      template_prep_kit_box_barcode: existing_pool.template_prep_kit_box_barcode,
                      insert_size: existing_pool.insert_size,
                      created_at: '2021-08-04T14:35:47.208Z',
                      updated_at: '2021-08-04T14:35:47.208Z'
                    }
                  }
                ]
              }
            }
          }.to_json
        end

        it 'has a unprocessable_content status' do
          expect(response).to have_http_status(:unprocessable_content), response.body
        end

        it 'does not update the multi pool or associated data' do
          mp.reload
          expect(mp.pool_method).to eq('Plate')
        end

        it 'returns the correct error messages' do
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['errors']
          expect(errors[0]['detail']).to eq 'multi_pool_positions.pacbio_pool.tags - contain duplicates'
        end
      end

      context 'when updating a multi pool (removing an in-use pool)' do
        let(:pool_to_destroy) do
          # Simulate the pool being in-use by using a pool from a run
          run = create(:pacbio_revio_run)
          run.wells.first.pools.first
        end
        let(:position_to_destroy) { build(:multi_pool_position, position: 'A2', pool: pool_to_destroy) }
        let!(:mp) do
          mp = create(:multi_pool)
          # Ensure the existing pool has position A1
          mp.multi_pool_positions.first.position = 'A1'
          # Create a second existing pool to remove
          mp.multi_pool_positions << position_to_destroy
          mp
        end
        let!(:existing_pool) { mp.multi_pool_positions.first.pacbio_pool }
        let(:body) do
          {
            data: {
              id: mp.id.to_s,
              type: 'multi_pools',
              attributes: {
                pipeline: 'pacbio',
                pool_method: 'Plate',
                multi_pool_positions_attributes: [
                  {
                    id: mp.multi_pool_positions.first.id.to_s,
                    position: mp.multi_pool_positions.first.position,
                    pacbio_pool_attributes: {
                      id: existing_pool.id.to_s,
                      used_aliquots_attributes: [{
                        id: existing_pool.used_aliquots.first.id.to_s,
                        volume: existing_pool.used_aliquots.first.volume,
                        concentration: existing_pool.used_aliquots.first.concentration,
                        template_prep_kit_box_barcode: existing_pool.used_aliquots.first.template_prep_kit_box_barcode,
                        insert_size: existing_pool.used_aliquots.first.insert_size,
                        source_id: existing_pool.used_aliquots.first.source_id,
                        source_type: existing_pool.used_aliquots.first.source_type
                      }],
                      primary_aliquot_attributes: {
                        id: existing_pool.primary_aliquot.id.to_s,
                        volume: existing_pool.primary_aliquot.volume,
                        concentration: existing_pool.primary_aliquot.concentration,
                        template_prep_kit_box_barcode: existing_pool.primary_aliquot.template_prep_kit_box_barcode,
                        insert_size: existing_pool.primary_aliquot.insert_size
                      },
                      volume: existing_pool.volume,
                      concentration: existing_pool.concentration,
                      template_prep_kit_box_barcode: existing_pool.template_prep_kit_box_barcode,
                      insert_size: existing_pool.insert_size,
                      created_at: '2021-08-04T14:35:47.208Z',
                      updated_at: '2021-08-04T14:35:47.208Z'
                    }
                  },
                  {
                    id: position_to_destroy.id.to_s,
                    _destroy: true
                  }
                ]
              }
            }
          }.to_json
        end

        it 'returns an internal_server_error status and error message' do
          # This isn't ideal - we should be returning unprocessable_entity
          # but due to the way JSONAPI::Resources handles nested destroy errors
          # we end up with a generic 500 error.
          expect(response).to have_http_status(:internal_server_error), response.body
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['errors']
          expect(errors[0]['meta']['exception']).to eq 'Cannot delete pool because it is in use in a run'
        end

        it 'does not update the multi_pool' do
          mp.reload
          expect(mp.number_of_pools).to eq(2)
        end

        it 'retains the existing pool position and pool' do
          expect(MultiPoolPosition.find(position_to_destroy.id)).to eq(position_to_destroy)
          expect(Pacbio::Pool.find(pool_to_destroy.id)).to eq(pool_to_destroy)
        end
      end
    end
  end
end
