# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PlatesController' do
  before do
    # Create a default smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v10', default: true)
  end

  describe '#get' do
    let!(:run1) { create(:pacbio_run) }
    let!(:run2) { create(:pacbio_run) }
    let!(:plate1) { create(:pacbio_plate, run: run1) }
    let!(:plate2) { create(:pacbio_plate, run: run2) }
    let!(:wells) { create_list(:pacbio_well, 5, plate: plate2) }

    it 'returns a list of plates' do
      get v1_pacbio_runs_plates_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get "#{v1_pacbio_runs_plates_path}?include=wells", headers: json_api_headers

      expect(response).to have_http_status(:success), response.body
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['attributes']['pacbio_run_id']).to eq(plate1.pacbio_run_id)
      expect(json['data'][1]['attributes']['pacbio_run_id']).to eq(plate2.pacbio_run_id)

      wells = json['included']
      expect(wells.length).to eq(5)

      well = wells[0]['attributes']
      plate_well = plate2.wells.first
      expect(well['on_plate_loading_concentration']).to eq(plate_well.on_plate_loading_concentration)
    end
  end

  describe '#create' do
    let(:run) { create(:pacbio_run) }

    context 'on success' do
      let(:body) do
        {
          data: {
            type: 'plates',
            attributes: {
              pacbio_run_id: run.id
            }
          }
        }.to_json
      end

      it 'has a ok status' do
        post v1_pacbio_runs_plates_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a plate' do
        expect do
          post v1_pacbio_runs_plates_path, params: body, headers: json_api_headers
        end.to change(Pacbio::Plate, :count).by(1)
      end

      it 'has the correct attributes' do
        post v1_pacbio_runs_plates_path, params: body, headers: json_api_headers
        plate = Pacbio::Plate.first
        expect(plate.run).to eq run
      end
    end

    context 'on failure' do
      let(:body) do
        {
          data: {
            type: 'plates',
            attributes: {
              pacbio_run_id: 0
            }
          }
        }.to_json
      end

      it 'has a ok unprocessable_entity' do
        post v1_pacbio_runs_plates_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a plate' do
        expect do
          post v1_pacbio_runs_plates_path, params: body,
                                           headers: json_api_headers
        end.not_to change(Pacbio::Plate, :count)
      end

      it 'has an error message' do
        post v1_pacbio_runs_plates_path, params: body, headers: json_api_headers
        json = ActiveSupport::JSON.decode(response.body)
        errors = json['data']['errors']
        expect(errors['run']).to be_present
      end
    end
  end

  describe '#update' do
    let(:plate) { create(:pacbio_plate) }
    let(:new_run) { create(:pacbio_run) }

    context 'on success' do
      let(:body) do
        {
          data: {
            type: 'plates',
            id: plate.id,
            attributes: {
              pacbio_run_id: new_run.id
            }
          }
        }.to_json
      end

      it 'has a ok status' do
        patch v1_pacbio_runs_plate_path(plate), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates a plate' do
        patch v1_pacbio_runs_plate_path(plate), params: body, headers: json_api_headers
        plate.reload
        expect(plate.run).to eq new_run
      end

      it 'returns the correct attributes' do
        patch v1_pacbio_runs_plate_path(plate), params: body, headers: json_api_headers
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['id']).to eq plate.id.to_s
      end
    end

    context 'on failure' do
      let(:body) do
        {
          data: {
            type: 'plates',
            id: plate.id,
            attributes: {
              pacbio_run_id: new_run.id
            }
          }
        }.to_json
      end

      it 'has a ok unprocessable_entity' do
        patch v1_pacbio_runs_plate_path(123), params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        patch v1_pacbio_runs_plate_path(123), params: body, headers: json_api_headers
        expect(JSON.parse(response.body)['data']).to include('errors' => "Couldn't find Pacbio::Plate with 'id'=123")
      end
    end
  end

  describe '#destroy' do
    let!(:plate) { create(:pacbio_plate) }
    let!(:well) { create(:pacbio_well, pacbio_plate_id: plate.id) }

    context 'on success' do
      it 'has a status of ok' do
        delete v1_pacbio_runs_plate_path(plate), headers: json_api_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'deletes the plate' do
        expect { delete v1_pacbio_runs_plate_path(plate), headers: json_api_headers }.to change(Pacbio::Plate, :count).by(-1)
      end

      it 'deletes the wells' do
        expect { delete v1_pacbio_runs_plate_path(plate), headers: json_api_headers }.to change(Pacbio::Well, :count).by(-1)
      end
    end

    context 'on failure' do
      it 'does not delete the plate' do
        delete '/v1/pacbio/runs/plates/123', headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        delete '/v1/pacbio/runs/plates/123', headers: json_api_headers
        data = JSON.parse(response.body)['data']
        expect(data['errors']).to be_present
      end
    end
  end
end
