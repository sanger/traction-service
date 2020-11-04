require "rails_helper"

RSpec.describe 'RequestLibraryController', type: :request do

    context '#update' do
        let(:tag) { create(:tag) }
        let(:request_library) { create(:pacbio_request_library) }

        context 'on success' do
            let(:body) do
                {
                    data: {
                        type: "tags",
                        id: request_library.id,
                        attributes: {
                            tag_id: tag.id
                        }
                    }
                }.to_json
            end

            it 'has a ok status' do
                patch v1_pacbio_request_library_path(request_library), params: body, headers: json_api_headers
                expect(response).to have_http_status(:ok)
            end

            it 'returns the correct attributes' do
                patch v1_pacbio_request_library_path(request_library), params: body, headers: json_api_headers
                json = ActiveSupport::JSON.decode(response.body)
                expect(json['data']['id']).to eq request_library.id.to_s
            end
        end

        context 'on failure' do
            let(:body) do
                {
                    data: {
                        type: "tags",
                        id: request_library.id,
                        attributes: {}
                    }
                }.to_json
            end

            it 'fails when tag_id is missing' do
                patch v1_pacbio_request_library_path(request_library), params: body, headers: json_api_headers
                expect(response).to have_http_status(:unprocessable_entity)
            end
        end
    end

end
