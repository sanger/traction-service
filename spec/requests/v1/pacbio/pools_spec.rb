require "rails_helper"

RSpec.describe 'LibrariesController', type: :request, pacbio: true do

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
                libraries: [
                  {
                    template_prep_kit_box_barcode: 'LK1234567',
                    volume: 1.11,
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
          json = ActiveSupport::JSON.decode(response.body)
          expect(json["model"]["id"].to_i).to eq(Pacbio::Pool.first.id)
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

  # context '#destroy' do
  #   context 'on success' do
  #     let!(:library) { create(:pacbio_library) }
  #     let!(:request_library)        { create(:pacbio_request_library_with_tag, library: library) }

  #     it 'returns the correct status' do
  #       delete "/v1/pacbio/libraries/#{library.id}", headers: json_api_headers
  #       expect(response).to have_http_status(:no_content)
  #     end

  #     it 'destroys the library' do
  #       expect { delete "/v1/pacbio/libraries/#{library.id}", headers: json_api_headers }.to change { Pacbio::Library.count }.by(-1)
  #     end

  #     it 'destroys the libraries request libraries' do
  #       expect { delete "/v1/pacbio/libraries/#{library.id}", headers: json_api_headers }.to change { Pacbio::RequestLibrary.count }.by(-1)
  #     end

  #   end

  #   context 'on failure' do
  #     it 'does not delete the library' do
  #       delete "/v1/pacbio/libraries/dodgyid", headers: json_api_headers
  #       expect(response).to have_http_status(:unprocessable_entity)
  #     end

  #     it 'has an error message' do
  #       delete "/v1/pacbio/libraries/dodgyid", headers: json_api_headers
  #       data = JSON.parse(response.body)['data']
  #       expect(data['errors']).to be_present
  #     end
  #   end
  # end

end
