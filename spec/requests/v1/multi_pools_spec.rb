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
      expect(json['data'][0]['attributes']['created_at']).to eq(multi_pool1.created_at.to_fs(:us))

      expect(json['data'][1]['attributes']['pool_method']).to eq(multi_pool2.pool_method)
      expect(json['data'][1]['attributes']['pipeline']).to eq(multi_pool2.pipeline)
      expect(json['data'][1]['attributes']['created_at']).to eq(multi_pool2.created_at.to_fs(:us))
    end
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

        pacbio_pool_resource = find_included_resource(type: 'pools', id: pacbio_pool.id)
        expect(pacbio_pool_resource.dig('attributes', 'volume')).to eq(pacbio_pool.volume)
      end
    end

    describe 'ont data', skip: 'Ont is not yet supported' do
      let!(:multi_pools) do
        mps = build_list(:multi_pool, 5)
        mps.each do |mp|
          mp.multi_pool_positions = build_list(:multi_pool_position, 1, pool: create(:ont_pool))
          mp.save
        end
        mps
      end
      let(:multi_pool_relationships) do
        multi_pool_resource = find_resource(type: 'multi_pools', id: multi_pools.first.id)
        multi_pool_resource.fetch('relationships')
      end
      let(:multi_pool) { multi_pools.first }

      before do
        get "#{v1_multi_pools_path}?include=multi_pool_positions.ont_pool",
            headers: json_api_headers
      end

      it 'has a success status' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the correct relationships and included data', :aggregate_failures do
        multi_pool_position = multi_pool.multi_pool_positions.first
        ont_pool = multi_pool_position.pool
        multi_pool_positions_relationship = multi_pool_relationships.dig('multi_pool_positions', 'data')
        expect(multi_pool_positions_relationship[0]['id']).to eq(multi_pool_position.id.to_s)
        expect(multi_pool_positions_relationship[0]['type']).to eq('multi_pool_positions')

        multi_pool_position_resource = find_included_resource(type: 'multi_pool_positions', id: multi_pool_position.id)
        expect(multi_pool_position_resource.dig('attributes', 'position')).to eq(multi_pool_position.position)

        ont_pool_resource = find_included_resource(type: 'pools', id: ont_pool.id)
        expect(ont_pool_resource.dig('attributes', 'volume')).to eq(ont_pool.volume)
      end
    end
  end
end
