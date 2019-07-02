require "rails_helper"

RSpec.describe 'WellsController', type: :request do

  let(:library) { create(:pacbio_library) }

  context '#create' do

    let(:plate) { create(:pacbio_plate) }

    context 'on success' do
      let(:body) do
        {
          data: {
            type: "wells",
            attributes: {
              'row': 'A',
              'column': '01',
              'movie_time': 8,
              'insert_size': 8000,
              'on_plate_loading_concentration': 8.35,
              'pacbio_plate_id': plate.id
            }
          }
        }.to_json
      end

      it 'has a created status' do
        post v1_pacbio_wells_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a well' do
        expect { post v1_pacbio_wells_path, params: body, headers: json_api_headers }.to change(Pacbio::Well, :count).by(1)
      end

    end

    context 'on failure' do
      let(:body) do
        {
          data: {
            type: "wells",
            attributes: {
              'row': 'A',
              'column': '01',
              'insert_size': 8000,
              'on_plate_loading_concentration': 8.35,
              'pacbio_plate_id': plate.id
            }
          }
        }.to_json
      end

      it 'has a ok unprocessable_entity' do
        post v1_pacbio_wells_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a flowcell' do
        expect { post v1_pacbio_wells_path, params: body, headers: json_api_headers }.to_not change(Pacbio::Well, :count)
      end

      it 'has the correct error messages' do
        post v1_pacbio_wells_path, params: body, headers: json_api_headers
        json = ActiveSupport::JSON.decode(response.body)
        errors = json['data']['errors']
        expect(errors['movie_time']).to be_present
      end
    end
  end

  context '#update' do
    let(:well) { create(:pacbio_well) }

    context 'on success' do
      let(:body) do
        {
          data: {
            type: "wells",
            id: well.id,
            attributes: {
              "movie_time": 1
            }
          }
        }.to_json
      end

      it 'has a ok status' do
        patch v1_pacbio_well_path(well), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates a well' do
        patch v1_pacbio_well_path(well), params: body, headers: json_api_headers
        well.reload
        expect(well.movie_time).to eq 1
      end

      it 'returns the correct attributes' do
        patch v1_pacbio_well_path(well), params: body, headers: json_api_headers
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['id']).to eq well.id.to_s
      end
    end

    context 'on failure' do
      let(:body) do
        {
          data: {
            type: "wells",
            id: 123,
            attributes: {
              "movie_time": 1
            }
          }
        }.to_json
      end

      it 'has a ok unprocessable_entity' do
        patch v1_pacbio_well_path(123), params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        patch v1_pacbio_well_path(123), params: body, headers: json_api_headers
        expect(JSON.parse(response.body)["data"]).to include("errors" => "Couldn't find Pacbio::Well with 'id'=123")
      end
    end
  end

  context '#destroy' do

    let!(:well) { create(:pacbio_well) }

    it 'has a status of no content' do
      delete v1_pacbio_well_path(well), headers: json_api_headers
      expect(response).to have_http_status(:no_content)
    end

    it 'deletes the well' do
      expect { delete v1_pacbio_well_path(well), headers: json_api_headers }.to change { Pacbio::Well.count }.by(-1)
    end

  end

end
