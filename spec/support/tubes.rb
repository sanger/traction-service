# frozen_string_literal: true

require 'rails_helper'

shared_examples_for 'tubes' do
  let(:pipeline_tube_request_factory)       { :"tube_with_#{pipeline_name}_request" }
  let(:other_pipeline_tube_request_factory) { :"tube_with_#{other_pipeline_name}_request" }
  let(:pipeline_tube_pool_factory)       { :"tube_with_#{pipeline_name}_pool" }
  let(:other_pipeline_tube_pool_factory) { :"tube_with_#{other_pipeline_name}_pool" }
  let(:tubes_path) { "v1_#{pipeline_name}_tubes_path" }

  describe '#get' do
    context 'tubes' do
      it 'returns a list' do
        create_list(other_pipeline_tube_request_factory, 2)
        create_list(pipeline_tube_request_factory, 3)
        get send(tubes_path), headers: json_api_headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'].length).to eq(3)
      end
    end

    context 'when material is a request' do
      let!(:pipeline_tube_requests)        { create_list(pipeline_tube_request_factory, 2) }

      it 'returns the correct attributes', :aggregate_failures do
        create(other_pipeline_tube_request_factory)
        get send(tubes_path), headers: json_api_headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)

        tube0 = pipeline_tube_requests.first
        tube0_data = json['data'][0]
        expect(tube0_data['attributes']['barcode']).to eq(tube0.barcode)
        expect(tube0_data['relationships']['materials']).to be_present

        tube1 = pipeline_tube_requests.last
        tube1_data = json['data'][1]
        expect(tube1_data['attributes']['barcode']).to eq(tube1.barcode)
        expect(tube1_data['relationships']['materials']).to be_present
      end
    end

    context 'when material is a pool' do
      let!(:pipeline_tube_pools) { create_list(pipeline_tube_pool_factory, 2) }

      it 'returns the correct attributes' do
        create(other_pipeline_tube_pool_factory)
        get send(tubes_path), headers: json_api_headers
        expect(response).to have_http_status(:success)
        tube = pipeline_tube_pools.first
        tube_resource = find_resource(type: 'tubes', id: tube.id)
        expect(tube_resource['attributes']['barcode']).to eq(tube.barcode)
        expect(tube_resource['relationships']['materials']).to be_present

        tube = pipeline_tube_pools.last
        tube_resource = find_resource(type: 'tubes', id: tube.id)
        expect(tube_resource['attributes']['barcode']).to eq(tube.barcode)
        expect(tube_resource['relationships']['materials']).to be_present
      end
    end

    describe 'filter' do
      context 'when filtering by barcode' do
        let(:tubes_with_request) { create_list(pipeline_tube_request_factory, 2) }

        it 'returns the correct tube' do
          barcode = tubes_with_request[0].barcode
          get "#{send(tubes_path)}?filter[barcode]=#{barcode}", headers: json_api_headers
          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)
          expect(json['data'].length).to eq(1)
          expect(json['data'][0]['attributes']['barcode']).to eq barcode
        end
      end

      context 'filtering by barcodes' do
        let(:tubes_with_pool) { create_list(pipeline_tube_pool_factory, 4) }

        it 'returns the correct tubes' do
          barcodes = tubes_with_pool.map(&:barcode)[0..1]
          get "#{send(tubes_path)}?filter[barcode]=#{barcodes.join(',')}", headers: json_api_headers
          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)
          expect(json['data'].length).to eq(barcodes.length)
          expect(json['data'][0]['attributes']['barcode']).to eq barcodes[0]
          expect(json['data'][1]['attributes']['barcode']).to eq barcodes[1]
        end
      end
    end

    describe 'filter and include' do
      context 'when including material and the material is a request' do
        let(:tubes_with_request) { create_list(pipeline_tube_request_factory, 2) }

        it 'returns the request data' do
          tube = tubes_with_request[0]
          get "#{send(tubes_path)}?filter[barcode]=#{tube.barcode}&include=materials",
              headers: json_api_headers

          expect(response).to have_http_status(:success)

          json = ActiveSupport::JSON.decode(response.body)
          expect(json['data'].length).to eq(1)

          expect(json['included'][0]['id']).to eq tube.container_materials.first.id.to_s
          expect(json['included'][0]['type']).to be_present
          expect(json['included'][0]['attributes']['external_study_id']).to eq tube.materials.first.external_study_id
          expect(json['included'][0]['attributes']['sample_name']).to eq tube.materials.first.sample.name
          expect(json['included'][0]['attributes']['barcode']).to eq tube.barcode
          expect(json['included'][0]['attributes']['sample_species']).to eq tube.materials.first.sample.species
          expect(json['included'][0]['attributes']['created_at']).to eq tube.materials.first.sample.created_at.to_fs(:us)
          expect(json['included'][0]['attributes']['material_type']).to eq 'request'

          expect(json['data'][0]['relationships']['materials']['data'].count).to eq(1)
          expect(json['data'][0]['relationships']['materials']['data'].first['type']).to be_present
          expect(json['data'][0]['relationships']['materials']['data'].first['id'].to_s).to eq tube.container_materials.first.id.to_s
        end
      end
    end
  end
end
