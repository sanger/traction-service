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

  # context '#create' do
  #   context 'when creating a single library' do
  #     let!(:tag) { create(:pacbio_tag) }
  #     let!(:sample) { create(:sample) }

  #     context 'on success' do

  #       let(:body) do
  #         {
  #           data: {
  #             type: 'libraries',
  #             attributes: {
  #               libraries: [
  #                 { volume: 1.11,
  #                   concentration: 2.22,
  #                   library_kit_barcode: 'LK1234567',
  #                   fragment_size: 100,
  #                   pacbio_tag_id: tag.id,
  #                   sample_id: sample.id
  #                 }
  #               ]
  #             }
  #           }
  #         }.to_json
  #       end

  #       it 'has a created status' do
  #         post v1_pacbio_libraries_path, params: body, headers: json_api_headers
  #         expect(response).to have_http_status(:created)
  #       end

  #       it 'creates a library' do
  #         expect { post v1_pacbio_libraries_path, params: body, headers: json_api_headers }.to change { Pacbio::Library.count }.by(1)
  #       end

  #       it 'creates a library with a tube' do
  #         post v1_pacbio_libraries_path, params: body, headers: json_api_headers
  #         expect(Pacbio::Library.last.tube).to be_present
  #         tube_id = Pacbio::Library.last.tube.id
  #         expect(Tube.find(tube_id).material).to eq Pacbio::Library.last
  #       end

  #       it 'creates a library with a sample' do
  #         post v1_pacbio_libraries_path, params: body, headers: json_api_headers
  #         expect(Pacbio::Library.last.sample).to be_present
  #         sample_id = Pacbio::Library.last.sample.id
  #         expect(sample_id).to eq sample.id
  #       end
  #       it 'creates a library with the correct attributes' do
  #         post v1_pacbio_libraries_path, params: body, headers: json_api_headers
  #         library = Pacbio::Library.first
  #         expect(library.volume).to be_present
  #         expect(library.concentration).to be_present
  #         expect(library.library_kit_barcode).to be_present
  #         expect(library.fragment_size).to be_present
  #         expect(library.pacbio_tag_id).to be_present
  #         expect(library.sample_id).to be_present
  #       end
  #     end

  #     context 'on failure' do
  #       context 'when the sample does not exist' do      #
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
  #                   }
  #                 ]
  #               }
  #             }
  #           }.to_json
  #         end

  #         it 'can returns unprocessable entity status' do
  #           post v1_pacbio_libraries_path, params: body, headers: json_api_headers
  #           expect(response).to have_http_status(:unprocessable_entity)
  #         end

  #         it 'cannot create a library' do
  #           expect { post v1_pacbio_libraries_path, params: body, headers: json_api_headers }.to_not change(Pacbio::Library, :count)
  #         end

  #         it 'has an error message' do
  #           post v1_pacbio_libraries_path, params: body, headers: json_api_headers
  #           expect(JSON.parse(response.body)["data"]).to include("errors" => {"sample"=>['must exist']})
  #         end
  #       end
  #     #
  #       context 'when the tag does not exist' do
  #         let(:body) do
  #           {
  #             data: {
  #               attributes: {
  #                 libraries: [
  #                   { volume: 1.11,
  #                     concentration: 2.22,
  #                     library_kit_barcode: 'LK1234567',
  #                     fragment_size: 100,
  #                     pacbio_tag_id: 123,
  #                     sample_id: sample.id
  #                   }
  #                 ]
  #               }
  #             }
  #           }.to_json
  #         end

  #         it 'can returns unprocessable entity status' do
  #           post v1_pacbio_libraries_path, params: body, headers: json_api_headers
  #           expect(response).to have_http_status(:unprocessable_entity)
  #         end

  #         it 'cannot create a library' do
  #           expect { post v1_pacbio_libraries_path, params: body, headers: json_api_headers }.to_not change(Pacbio::Library, :count)
  #         end

  #         it 'has an error message' do
  #           post v1_pacbio_libraries_path, params: body, headers: json_api_headers
  #           expect(JSON.parse(response.body)["data"]).to include("errors" => {"tag"=>['must exist']})
  #         end
  #       end

  #     end

  #   end

  #   context 'when creating multiple libraries' do
  #     let(:sample) { create(:sample) }
  #     let(:tag) { create(:pacbio_tag) }

  #     context 'on success' do
  #       context 'when the sample does exist' do

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
  #                     sample_id: sample.id
  #                   },
  #                   { volume: 3.22,
  #                     concentration: 4.22,
  #                     library_kit_barcode: 'LK1234569',
  #                     fragment_size: 200,
  #                     pacbio_tag_id: tag.id,
  #                     sample_id: sample.id
  #                   }
  #                 ]
  #               }
  #             }
  #           }.to_json
  #         end

  #         it 'can create libraries' do
  #           post v1_pacbio_libraries_path, params: body, headers: json_api_headers
  #           expect(response).to have_http_status(:created)
  #         end
  #       end
  #     end

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

  #   end
  # end

  # context '#destroy' do
  #   context 'on success' do
  #     let!(:library) { create(:pacbio_library) }

  #     it 'returns the correct status' do
  #       delete "/v1/pacbio/libraries/#{library.id}", headers: json_api_headers
  #       expect(response).to have_http_status(:no_content)
  #     end

  #     it 'destroys the library' do
  #       expect { delete "/v1/pacbio/libraries/#{library.id}", headers: json_api_headers }.to change { Pacbio::Library.count }.by(-1)
  #     end

  #   end

  #   context 'on failure' do

  #     it 'does not delete the library' do
  #       delete "/v1/pacbio/libraries/123", headers: json_api_headers
  #       expect(response).to have_http_status(:unprocessable_entity)
  #     end

  #     it 'has an error message' do
  #       delete "/v1/pacbio/libraries/123", headers: json_api_headers
  #       data = JSON.parse(response.body)['data']
  #       expect(data['errors']).to be_present
  #     end
  #   end
  # end

end
