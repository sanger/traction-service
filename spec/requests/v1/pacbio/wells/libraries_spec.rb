require "rails_helper"

RSpec.describe 'Well::LibrariesController', type: :request, pacbio: true do

  let(:well)                  { create(:pacbio_well) }
  let(:request_libraries)     { create_list(:pacbio_request_library, 5)}
  let(:dodgy_request_library) { create(:pacbio_request_library, tag: request_libraries.first.tag) }

  context '#create' do

    context 'on success' do
      let(:body) do
        {
          data: {
            type: 'libraries',
            attributes: {
            },
            relationships: {
              libraries: {
                data: request_libraries.collect(&:library).collect { |library| { type: 'libraries', id: library.id} }
              }
            }
          }
        }.to_json
      end

      it 'has a created status' do
        post v1_pacbio_well_libraries_path(well), params: body, headers: json_api_headers
        expect(response).to have_http_status(:created)
      end

      it 'adds the libraries to the well' do
        expect { post v1_pacbio_well_libraries_path(well), params: body, headers: json_api_headers }.to change(well.libraries, :count).by(5)
      end
    end

    context 'on failure' do
      let(:body) do
        {
          data: {
            type: 'libraries',
            attributes: {
            },
            relationships: {
              libraries: {
                data: request_libraries.push(dodgy_request_library).collect(&:library).collect { |library| { type: 'libraries', id: library.id} }
              }
            }
          }
        }.to_json
      end

      it 'returns unprocessable entity status' do
        post v1_pacbio_well_libraries_path(well), params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'cannot create a library' do
        expect { post v1_pacbio_well_libraries_path(well), params: body, headers: json_api_headers }.to_not change(well.libraries, :count)
      end

      it 'has an error message' do
        post v1_pacbio_well_libraries_path(well), params: body, headers: json_api_headers
        expect(JSON.parse(response.body)["data"]).to include("errors" => {"tags" => ["are not unique within the libraries"]})
      end
    end
  end

end
