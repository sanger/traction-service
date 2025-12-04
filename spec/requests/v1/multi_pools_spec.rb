# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MultiPoolsController' do
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
  end

  describe '#create' do
    context 'when creating a multi pool with one pool' do
      context 'on success' do
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
          expect { post v1_multi_pools_path, params: body, headers: json_api_headers }.to change(MultiPool, :count).by(1).and change(MultiPoolPosition, :count).by(1).and change(Pacbio::Pool, :count).by(1)
        end

        it 'returns the id' do
          post v1_multi_pools_path, params: body, headers: json_api_headers
          expect(json.dig('data', 'id').to_i).to eq(MultiPool.first.id)
        end
      end
    end
  end
end
