require "rails_helper"

RSpec.describe 'PoolsController', type: :request, pacbio: true do

  let!(:request) { create(:pacbio_request) }
  let!(:tag) { create(:tag) }
  let!(:request2) { create(:pacbio_request) }
  let!(:tag2) { create(:tag) }

  context '#get' do

    let!(:pools) { create_list(:pacbio_pool, 2)}

    it 'returns a list of pools' do
      get v1_pacbio_pools_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns pool attributes', aggregate_failures: true do
      get v1_pacbio_pools_path, headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      pool_resource = json['data'][0]['attributes']
      pool = pools.first

      expect(pool_resource['source_identifier']).to eq(pool.source_identifier)
      expect(pool_resource['volume']).to eq(pool.volume)
      expect(pool_resource['concentration']).to eq(pool.concentration)
      expect(pool_resource['template_prep_kit_box_barcode']).to eq(pool.template_prep_kit_box_barcode)
      expect(pool_resource['fragment_size']).to eq(pool.fragment_size)
    end

    it 'returns the correct attributes', aggregate_failures: true do
      get "#{v1_pacbio_pools_path}?include=libraries", headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      library_attributes = json['included'][0]['attributes']
      library = pools.first.libraries.first

      expect(library_attributes['volume']).to eq(library.volume)
      expect(library_attributes['concentration']).to eq(library.concentration)
      expect(library_attributes['template_prep_kit_box_barcode']).to eq(library.template_prep_kit_box_barcode)
      expect(library_attributes['fragment_size']).to eq(library.fragment_size)
    end

  end

  context '#create' do
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
                fragment_size: 100,
                libraries: [
                  {
                    volume: 1.11,
                    template_prep_kit_box_barcode: 'LK1234567',
                    concentration: 2.22,
                    fragment_size: 100,
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
          expect(response).to have_http_status(:created)
        end

        it 'creates a pool' do
          expect { post v1_pacbio_pools_path, params: body, headers: json_api_headers }.to change { Pacbio::Pool.count }.by(1)
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
                  libraries: [
                    {
                      template_prep_kit_box_barcode: 'LK1234567',
                      volume: 1.11,
                      concentration: 2.22,
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
            expect { post v1_pacbio_pools_path, params: body, headers: json_api_headers }.to_not change(Pacbio::Pool, :count)
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
                libraries: [
                  {
                    template_prep_kit_box_barcode: 'LK1234567',
                    volume: 1.11,
                    concentration: 2.22,
                    fragment_size: 100,
                    pacbio_request_id: request.id,
                    tag_id: tag.id
                  },
                  {
                    template_prep_kit_box_barcode: 'LK1234567',
                    volume: 1.11,
                    concentration: 2.22,
                    fragment_size: 100,
                    pacbio_request_id: request2.id,
                    tag_id: tag2.id
                  }
                ]
              }
            }
          }.to_json
        end

        it 'returns created  status' do
          post v1_pacbio_pools_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created)
        end

        it 'creates a pool' do
          expect { post v1_pacbio_pools_path, params: body, headers: json_api_headers }.to change(Pacbio::Pool, :count).by(1)
        end

      end

      context 'on failure' do
        context 'when there is a tag clash' do
          let(:body) do
            {
              data: {
                type: 'pools',
                attributes: {
                  libraries: [
                    {
                      template_prep_kit_box_barcode: 'LK1234567',
                      volume: 1.11,
                      concentration: 2.22,
                      fragment_size: 100,
                      pacbio_request_id: request.id,
                      tag_id: tag.id
                    },
                    {
                      template_prep_kit_box_barcode: 'LK1234567',
                      volume: 1.11,
                      concentration: 2.22,
                      fragment_size: 100,
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
            expect { post v1_pacbio_pools_path, params: body, headers: json_api_headers }.to_not change(Pacbio::Pool, :count)
          end

        end
      end
    end

  end

end
