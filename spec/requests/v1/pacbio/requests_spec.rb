require "rails_helper"

RSpec.describe 'RequestsController', type: :request, pacbio: true do

  context '#get' do
    let!(:pacbio_requests) { create_list(:pacbio_request, 2)}

    it 'returns a list of requests' do
      get v1_pacbio_requests_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      request = pacbio_requests.first

      get v1_pacbio_requests_path, headers: json_api_headers
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['attributes']['library_type']).to eq(request.library_type)
      expect(json['data'][0]['attributes']['estimate_of_gb_required']).to eq(request.estimate_of_gb_required)
      expect(json['data'][0]['attributes']['number_of_smrt_cells']).to eq(request.number_of_smrt_cells)
      expect(json['data'][0]['attributes']['cost_code']).to eq(request.cost_code)
      expect(json['data'][0]["attributes"]['external_study_id']).to eq(request.external_study_id)
      expect(json['data'][0]["attributes"]['sample_name']).to eq(request.sample_name)

    end
  end

  context '#create' do
    context 'when creating a single request' do

      context 'on success' do

        let(:body) do
          {
            data: {
              type: 'requests',
              attributes: {
                requests: [
                  {
                    'library_type': 'library_type_1',
                    'estimate_of_gb_required': 3,
                    'number_of_smrt_cells': 3,
                    'cost_code': 'cost_code_1',
                    'external_study_id': 1,
                    'name': 'sample1',
                    'external_id': 1,
                    'species': 'human'
                  }
                ]
              }
            }
          }.to_json
        end

        it 'has a created status' do
          post v1_pacbio_requests_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created)
        end

        it 'creates a request' do
          expect { post v1_pacbio_requests_path, params: body, headers: json_api_headers }.to change { Pacbio::Request.count }.by(1)
        end

        it 'creates a sample' do
          expect { post v1_pacbio_requests_path, params: body, headers: json_api_headers }.to change { Sample.count }.by(1)
        end
      end

      context 'on failure' do
         let(:body) do
          {
            data: {
              type: 'requests',
              attributes: {
                requests: [
                  {
                    'library_type': 'library_type_1',
                    'estimate_of_gb_required': 3,
                    'number_of_smrt_cells': 3,
                    'cost_code': 'cost_code_1',
                    'external_study_id': 1,
                    'external_id': 1,
                    'species': 'human'
                  }
                ]
              }
            }
          }.to_json
        end

        it 'can returns unprocessable entity status' do
          post v1_pacbio_requests_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'cannot create a request' do
          expect { post v1_pacbio_requests_path, params: body, headers: json_api_headers }.to_not change(Pacbio::Request, :count)
        end

        it 'has an error message' do
          post v1_pacbio_requests_path, params: body, headers: json_api_headers
          expect(JSON.parse(response.body)["data"]).to include("errors" => {"sample"=>['is invalid']})
        end
 
      end

    end

    context 'when creating multiple requests' do
  
      context 'on success' do
        context 'when the sample does exist' do

          let(:body) do
            {
              data: {
                attributes: {
                  requests: [
                    {
                      'library_type': 'library_type_1',
                      'estimate_of_gb_required': 3,
                      'number_of_smrt_cells': 3,
                      'cost_code': 'cost_code_1',
                      'external_study_id': 1,
                      'name': 'sample1',
                      'external_id': 1,
                      'species': 'human'
                    },
                    {
                      'library_type': 'library_type_1',
                      'estimate_of_gb_required': 3,
                      'number_of_smrt_cells': 3,
                      'cost_code': 'cost_code_1',
                      'external_study_id': 1,
                      'name': 'sample2',
                      'external_id': 2,
                      'species': 'human'
                    }
                  ]
                }
              }
            }.to_json
          end

          it 'can create requests' do
            post v1_pacbio_requests_path, params: body, headers: json_api_headers
            expect(response).to have_http_status(:created)
          end

          it 'will have the correct number of requests' do
            expect { post v1_pacbio_requests_path, params: body, headers: json_api_headers }.to change(Pacbio::Request, :count).by(2)
          end
        end
      end

  #     context 'on failure' do
  #       context 'when the sample does not exist' do

  #         let(:body) do
  #           {
  #             data: {
  #               attributes: {
  #                 libraries: [
  #                   { volume: 1.11,
  #                     concentration: 2.22,
  #                     library_kit_barcode: 'LK1234567',
  #                     fragment_size: 100,
  #                     pacbio_tag_id: tag.id,
  #                     sample_id: 123
  #                   },
  #                   { volume: 3.22,
  #                     concentration: 4.22,
  #                     library_kit_barcode: 'LK1234569',
  #                     fragment_size: 200,
  #                     pacbio_tag_id: tag.id,
  #                     sample_id: 123
  #                   }
  #                 ]
  #               }
  #             }
  #           }.to_json
  #         end

  #         it 'cannot create libraries' do
  #           post v1_pacbio_libraries_path, params: body, headers: json_api_headers
  #           expect(response).to have_http_status(:unprocessable_entity)
  #         end

  #         it 'has an error message' do
  #           post v1_pacbio_libraries_path, params: body, headers: json_api_headers
  #           expect(JSON.parse(response.body)["data"]).to include("errors" => {"sample"=>['must exist', 'must exist']})
  #         end
  #       end
  #     end

    end
  end

  context '#destroy' do

    let!(:pacbio_request) { create(:pacbio_request) }

    context 'on success' do

      it 'returns the correct status' do
        delete v1_pacbio_request_path(pacbio_request.id), headers: json_api_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'destroys the request' do
        expect { delete v1_pacbio_request_path(pacbio_request.id), headers: json_api_headers }.to change { Pacbio::Request.count }.by(-1)
      end

    end

    context 'on failure' do

      it 'does not delete the request' do
        delete v1_pacbio_request_path(123), headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        delete v1_pacbio_request_path(123), headers: json_api_headers
        data = JSON.parse(response.body)['data']
        expect(data['errors']).to be_present
      end
    end
  end

end
