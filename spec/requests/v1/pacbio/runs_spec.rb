require "rails_helper"

RSpec.describe 'RunsController', type: :request do

  context '#get' do
    let!(:run1) { create(:pacbio_run) }
    let!(:run2) { create(:pacbio_run) }
    let!(:plate1) { create(:pacbio_plate, run: run1) }
    let!(:plate2) { create(:pacbio_plate, run: run2) }

    it 'returns a list of runs' do
      get v1_pacbio_runs_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get v1_pacbio_runs_path, headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['attributes']['name']).to eq(run1.name)
      expect(json['data'][0]['attributes']['template_prep_kit_box_barcode']).to eq(run1.template_prep_kit_box_barcode)
      expect(json['data'][0]['attributes']['binding_kit_box_barcode']).to eq(run1.binding_kit_box_barcode)
      expect(json['data'][0]["attributes"]["sequencing_kit_box_barcode"]).to eq(run1.sequencing_kit_box_barcode)
      expect(json['data'][0]['attributes']['dna_control_complex_box_barcode']).to eq(run1.dna_control_complex_box_barcode)
      expect(json['data'][0]['attributes']['system_name']).to eq(run1.system_name)

      expect(json['data'][1]['attributes']['name']).to eq(run2.name)
      expect(json['data'][1]['attributes']['template_prep_kit_box_barcode']).to eq(run2.template_prep_kit_box_barcode)
      expect(json['data'][1]['attributes']['binding_kit_box_barcode']).to eq(run2.binding_kit_box_barcode)
      expect(json['data'][1]["attributes"]["sequencing_kit_box_barcode"]).to eq(run2.sequencing_kit_box_barcode)
      expect(json['data'][1]['attributes']['dna_control_complex_box_barcode']).to eq(run2.dna_control_complex_box_barcode)
      expect(json['data'][1]['attributes']['system_name']).to eq(run2.system_name)
    end

    it 'returns the correct relationships' do
      get "#{v1_pacbio_runs_path}?include=plate", headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['relationships']['plate']).to be_present
      expect(json['data'][0]['relationships']['plate']['data']['type']).to eq "plates"
      expect(json['data'][0]['relationships']['plate']['data']['id']).to eq plate1.id.to_s

      expect(json['data'][1]['relationships']['plate']).to be_present
      expect(json['data'][1]['relationships']['plate']['data']['type']).to eq "plates"
      expect(json['data'][1]['relationships']['plate']['data']['id']).to eq plate2.id.to_s
    end

  end

  context '#create' do
    let(:body) do
      {
        data: {
          type: "runs",
          attributes: attributes_for(:pacbio_run)
        }
      }.to_json
    end

    context 'on success' do
      it 'has a created status' do
        post v1_pacbio_runs_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a run' do
        expect { post v1_pacbio_runs_path, params: body, headers: json_api_headers }.to change { Pacbio::Run.count }.by(1)
      end

      it 'creates a run with the correct attributes' do
        post v1_pacbio_runs_path, params: body, headers: json_api_headers
        run = Pacbio::Run.first
        expect(run.name).to be_present
        expect(run.template_prep_kit_box_barcode).to be_present
        expect(run.binding_kit_box_barcode).to be_present
        expect(run.sequencing_kit_box_barcode).to be_present
        expect(run.dna_control_complex_box_barcode).to be_present
        expect(run.system_name).to be_present
      end

    end

    context 'on failure' do
      let(:body) do
        {
          data: {
            type: "runs",
            attributes: {}
          }
        }.to_json
      end

      it 'has a unprocessable_entity status' do
        post v1_pacbio_runs_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a run' do
        expect { post v1_pacbio_runs_path, params: body, headers: json_api_headers }.to_not change(Pacbio::Run, :count)
      end

      it 'has the correct error messages' do
        post v1_pacbio_runs_path, params: body, headers: json_api_headers
        json = ActiveSupport::JSON.decode(response.body)
        errors = json['data']['errors']
        expect(errors['name']).to be_present
        expect(errors['template_prep_kit_box_barcode']).to be_present
        expect(errors['binding_kit_box_barcode']).to be_present
        expect(errors['sequencing_kit_box_barcode']).to be_present
        expect(errors['dna_control_complex_box_barcode']).to be_present
      end

    end
  end

  context '#update' do

    before do
      @run = create(:pacbio_run)
      @plate = create(:pacbio_plate, run: @run)
    end

    context 'on success' do
      let(:body) do
        {
          data: {
            type: "runs",
            id: @run.id,
            attributes: {
              name: "an updated name"
            }
          }
        }.to_json
      end

      it 'has a ok status' do
        patch v1_pacbio_run_path(@run), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates a run' do
        patch v1_pacbio_run_path(@run), params: body, headers: json_api_headers
        @run.reload
        expect(@run.name).to eq "an updated name"
      end

      it 'returns the correct attributes' do
        patch v1_pacbio_run_path(@run), params: body, headers: json_api_headers
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['id']).to eq @run.id.to_s
      end

    end

    context 'on failure' do
      let(:body) do
        {
          data: {
            type: "runs",
            id: 123,
            attributes: {
              name: "an updated name"
            }
          }
        }.to_json
      end

      it 'has a ok unprocessable_entity' do
        patch v1_pacbio_run_path(123), params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        patch v1_pacbio_run_path(123), params: body, headers: json_api_headers
        expect(JSON.parse(response.body)["data"]).to include("errors" => "Couldn't find Pacbio::Run with 'id'=123")
      end
    end

  end

  context '#show' do
    let!(:run) { create(:pacbio_run) }
    let!(:plate) { create(:pacbio_plate, run: run) }

    it 'returns the runs' do
      get v1_pacbio_run_path(run), headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['id']).to eq(run.id.to_s)
    end

    it 'returns the correct attributes' do
      get v1_pacbio_run_path(run), headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data']['id']).to eq(run.id.to_s)
      expect(json['data']['attributes']['name']).to eq(run.name)
      expect(json['data']['attributes']['template_prep_kit_box_barcode']).to eq(run.template_prep_kit_box_barcode)
      expect(json['data']['attributes']['binding_kit_box_barcode']).to eq(run.binding_kit_box_barcode)
      expect(json['data']["attributes"]["sequencing_kit_box_barcode"]).to eq(run.sequencing_kit_box_barcode)
      expect(json['data']['attributes']['dna_control_complex_box_barcode']).to eq(run.dna_control_complex_box_barcode)
      expect(json['data']['attributes']['system_name']).to eq(run.system_name)
    end

    it 'returns the correct relationships' do
      get "#{v1_pacbio_run_path(run)}?include=plate", headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data']['relationships']['plate']).to be_present
      expect(json['data']['relationships']['plate']['data']['type']).to eq "plates"
      expect(json['data']['relationships']['plate']['data']['id']).to eq plate.id.to_s
    end

    it 'returns the correct includes' do
      get "#{v1_pacbio_run_path(run)}?include=plate", headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['included'][0]['id']).to eq plate.id.to_s
      expect(json['included'][0]['type']).to eq "plates"
    end

  end

  context '#destroy' do

    let!(:run) { create(:pacbio_run) }
    let!(:plate1) { create(:pacbio_plate, run: run) }

    context 'on success' do
      it 'returns the correct status' do
        delete v1_pacbio_run_path(run), headers: json_api_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'deletes the run' do
        expect { delete v1_pacbio_run_path(run), headers: json_api_headers }.to change { Pacbio::Run.count }.by(-1)
      end

      it 'deletes the plate' do
        expect { delete v1_pacbio_run_path(run), headers: json_api_headers }.to change { Pacbio::Plate.count }.by(-1)
      end

    end

    context 'on failure' do

      it 'does not delete the run' do
        delete "/v1/pacbio/runs/123", headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        delete "/v1/pacbio/runs/123", headers: json_api_headers
        data = JSON.parse(response.body)['data']
        expect(data['errors']).to be_present
      end
    end
  end

  context '#sample_sheet' do
    after(:each) { File.delete('sample_sheet.csv') if File.exists?('sample_sheet.csv') }

    let(:well1)   { create(:pacbio_well_with_libraries, sequencing_mode: 'CCS') }
    let(:well2)   { create(:pacbio_well_with_libraries, sequencing_mode: 'CLR') }
    let(:plate)   { create(:pacbio_plate, wells: [well1, well2]) }
    let(:run)     { create(:pacbio_run, plate: plate) }

    it 'returns the correct status' do
      get "#{v1_pacbio_run_sample_sheet_path(run)}", headers: json_api_headers
      expect(response).to have_http_status(:success)
    end

    it 'returns a CSV file' do
      get "#{v1_pacbio_run_sample_sheet_path(run)}", headers: json_api_headers
      expect(response.header['Content-Type']).to include 'text/csv'
    end
  end
end
