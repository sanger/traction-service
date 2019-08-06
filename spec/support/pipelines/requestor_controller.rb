require "rails_helper"

shared_examples_for 'requestor controller' do

  let(:request_factory)   { "#{pipeline_name}_request".to_sym }
  let(:requests_path)        { "v1_#{pipeline_name}_requests_path" }
  let(:request_path)       { "v1_#{pipeline_name}_request_path" }
  let(:pipeline_module) { pipeline_name.capitalize.constantize }
  let(:request_model) { "#{pipeline_name.capitalize}::Request".constantize }

  context '#get' do
    let!(:pipeline_requests) { create_list(request_factory, 2)}

    it 'returns a list of requests' do
      get send(requests_path), headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      request = pipeline_requests.first

      get send(requests_path), headers: json_api_headers
      json = ActiveSupport::JSON.decode(response.body)

      pipeline_module.request_attributes.each do |attribute|
        expect(json['data'][0]['attributes'][attribute.to_s]).to eq(request.send(attribute))
      end

      expect(json['data'][0]['attributes']['sample_name']).to eq(request.sample_name)

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
                  attributes_for(request_factory).merge(attributes_for(:sample))
                ]
              }
            }
          }.to_json
        end

        it 'has a created status' do
          post send(requests_path), params: body, headers: json_api_headers
          expect(response).to have_http_status(:created)
        end

        it 'creates a request' do
          expect { post send(requests_path), params: body, headers: json_api_headers }.to change { request_model.count }.by(1)
        end

        it 'creates a sample' do
          expect { post send(requests_path), params: body, headers: json_api_headers }.to change { Sample.count }.by(1)
        end

      end

      context 'on failure' do

        let(:body) do
          {
            data: {
              attributes: {
                requests: [
                  attributes_for(request_factory).merge(attributes_for(:sample).except(:name))
                ]
              }
            }
          }.to_json
        end

        it 'has an unprocessable entity status' do
          post send(requests_path), params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'cannot create a request' do
          expect { post send(requests_path), params: body, headers: json_api_headers }.to_not change(request_model, :count)
        end

        it 'has an error message' do
          post send(requests_path), params: body, headers: json_api_headers
          expect(JSON.parse(response.body)["data"]).to include("errors" => {"sample"=>['is invalid']})
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
                      attributes_for(request_factory).merge(attributes_for(:sample)),
                      attributes_for(request_factory).merge(attributes_for(:sample))
                    ]
                  }
                }
              }.to_json
            end

            it 'can create requests' do
              post send(requests_path), params: body, headers: json_api_headers
              expect(response).to have_http_status(:created)
            end

            it 'will have the correct number of requests' do
              expect { post send(requests_path), params: body, headers: json_api_headers }.to change(request_model, :count).by(2)
            end
          end
        end

      end
    end
  end

  context '#destroy' do

    let!(:pipeline_request) { create(request_factory) }

    context 'on success' do

      it 'returns the correct status' do
        delete send(request_path, pipeline_request.id), headers: json_api_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'destroys the request' do
        expect { delete send(request_path, pipeline_request.id), headers: json_api_headers }.to change { request_model.count }.by(-1)
      end

    end

    context 'on failure' do

      it 'does not delete the request' do
        delete send(request_path, 'fakerequest'), headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        delete send(request_path, 'fakerequest'), headers: json_api_headers
        data = JSON.parse(response.body)['data']
        expect(data['errors']).to be_present
      end
    end
  end
 
end