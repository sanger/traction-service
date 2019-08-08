require "rails_helper"

RSpec.describe 'WellsController', type: :request do

  context '#get' do
    let!(:well1) { create(:pacbio_well) }
    let!(:well2) { create(:pacbio_well) }

    it 'returns a list of wells' do
      get v1_pacbio_wells_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get v1_pacbio_wells_path, headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['attributes']['pacbio_plate_id']).to eq(well1.pacbio_plate_id)
      expect(json['data'][0]['attributes']['row']).to eq(well1.row)
      expect(json['data'][0]['attributes']['column']).to eq(well1.column)
      # TODO: fix movie time column
      expect(json['data'][0]['attributes']['movie_time'].to_s).to eq(well1.movie_time.to_s)
      expect(json['data'][0]['attributes']['insert_size']).to eq(well1.insert_size)
      expect(json['data'][0]['attributes']['on_plate_loading_concentration']).to eq(well1.on_plate_loading_concentration)
      expect(json['data'][0]['attributes']['pacbio_plate_id']).to eq(well1.pacbio_plate_id)
      expect(json['data'][0]['attributes']['comment']).to eq(well1.comment)
      expect(json['data'][0]['attributes']['sequencing_mode']).to eq(well1.sequencing_mode)

      expect(json['data'][1]['attributes']['pacbio_plate_id']).to eq(well2.pacbio_plate_id)
      expect(json['data'][1]['attributes']['row']).to eq(well2.row)
      expect(json['data'][1]['attributes']['column']).to eq(well2.column)
      expect(json['data'][1]['attributes']['movie_time'].to_s).to eq(well2.movie_time.to_s)
      expect(json['data'][1]['attributes']['insert_size']).to eq(well2.insert_size)
      expect(json['data'][1]['attributes']['on_plate_loading_concentration']).to eq(well2.on_plate_loading_concentration)
      expect(json['data'][1]['attributes']['pacbio_plate_id']).to eq(well2.pacbio_plate_id)
      expect(json['data'][1]['attributes']['comment']).to eq(well2.comment)
      expect(json['data'][1]['attributes']['sequencing_mode']).to eq(well2.sequencing_mode)
    end
  end

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
              'pacbio_plate_id': plate.id,
              'sequencing_mode': 'CLR'
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

      it 'does not create a well' do
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

    context 'on success' do
      it 'has a status of no content' do
        delete v1_pacbio_well_path(well), headers: json_api_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'deletes the well' do
        expect { delete v1_pacbio_well_path(well), headers: json_api_headers }.to change { Pacbio::Well.count }.by(-1)
      end
    end

    context 'on failure' do

      it 'does not delete the well' do
        delete "/v1/pacbio/wells/123", headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        delete "/v1/pacbio/wells/123", headers: json_api_headers
        data = JSON.parse(response.body)['data']
        expect(data['errors']).to be_present
      end
    end
  end

end
