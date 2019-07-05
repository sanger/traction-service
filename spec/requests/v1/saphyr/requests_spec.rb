require "rails_helper"

RSpec.describe 'RequestsController', type: :request, saphyr: true do

  context '#get' do
    let!(:saphyr_requests) { create_list(:saphyr_request, 2)}

    it 'returns a list of requests' do
      get v1_saphyr_requests_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      request = saphyr_requests.first

      get v1_saphyr_requests_path, headers: json_api_headers
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['attributes']['external_study_id']).to eq(request.external_study_id)
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

        it 'has a created status' do
          post v1_saphyr_requests_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created)
        end

        it 'creates a request' do
          expect { post v1_saphyr_requests_path, params: body, headers: json_api_headers }.to change { Saphyr::Request.count }.by(1)
        end

        it 'creates a sample' do
          expect { post v1_saphyr_requests_path, params: body, headers: json_api_headers }.to change { Sample.count }.by(1)
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
                    'external_study_id': 1,
                    'external_id': 2,
                    'species': 'human'
                  }
                ]
              }
            }
          }.to_json
        end

        it 'can returns unprocessable entity status' do
          post v1_saphyr_requests_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'cannot create a request' do
          expect { post v1_saphyr_requests_path, params: body, headers: json_api_headers }.to_not change(Saphyr::Request, :count)
        end

        it 'has an error message' do
          post v1_saphyr_requests_path, params: body, headers: json_api_headers
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
                      'external_study_id': 1,
                      'name': 'sample1',
                      'external_id': 1,
                      'species': 'human'
                    },
                    {
                      'external_study_id': 2,
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
            post v1_saphyr_requests_path, params: body, headers: json_api_headers
            expect(response).to have_http_status(:created)
          end

          it 'will have the correct number of requests' do
            expect { post v1_saphyr_requests_path, params: body, headers: json_api_headers }.to change(Saphyr::Request, :count).by(2)
          end
        end
      end

    end
  end

  context '#destroy' do

    let!(:saphyr_request) { create(:saphyr_request) }

    context 'on success' do

      it 'returns the correct status' do
        delete v1_saphyr_request_path(saphyr_request.id), headers: json_api_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'destroys the request' do
        expect { delete v1_saphyr_request_path(saphyr_request.id), headers: json_api_headers }.to change { Saphyr::Request.count }.by(-1)
      end

    end

    context 'on failure' do

      it 'does not delete the request' do
        delete v1_saphyr_request_path(123), headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        delete v1_saphyr_request_path(123), headers: json_api_headers
        data = JSON.parse(response.body)['data']
        expect(data['errors']).to be_present
      end
    end
  end

end
