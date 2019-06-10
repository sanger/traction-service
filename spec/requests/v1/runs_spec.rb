require "rails_helper"

RSpec.describe 'RunsController', type: :request do

  context '#get' do
    let!(:run1) { create(:run, state: 'pending', name: 'run1') }
    let!(:run2) { create(:run, state: 'started') }
    let!(:chip1) { create(:chip, run: run1) }
    let!(:chip2) { create(:chip, run: run2) }
    let!(:flowcells1) {create_list(:flowcell, 2, chip: chip1)}
    let!(:flowcells2) {create_list(:flowcell, 2, chip: chip2)}

    it 'returns a list of runs' do
      get v1_runs_path, headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'only returns active runs' do
      run3 = create(:run, deactivated_at: DateTime.now)
      get v1_runs_path, headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get v1_runs_path, headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'][0]['attributes']['state']).to eq(run1.state)
      expect(json['data'][0]['attributes']['name']).to eq(run1.name)
      expect(json['data'][0]['attributes']['chip_barcode']).to eq(run1.chip.barcode)
      expect(json['data'][0]["attributes"]["created_at"]).to eq(run1.created_at.strftime("%m/%d/%Y %H:%M"))
      expect(json['data'][1]['attributes']['state']).to eq(run2.state)
      expect(json['data'][1]['attributes']['name']).to eq(run2.name)
      expect(json['data'][1]['attributes']['chip_barcode']).to eq(run2.chip.barcode)
      expect(json['data'][1]["attributes"]["created_at"]).to eq(run2.created_at.strftime("%m/%d/%Y %H:%M"))
    end

    it 'returns the correct relationships' do
      get "#{v1_runs_path}?include=chip", headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['relationships']['chip']).to be_present
      expect(json['data'][0]['relationships']['chip']['data']['type']).to eq "chips"
      expect(json['data'][0]['relationships']['chip']['data']['id']).to eq chip1.id.to_s

      expect(json['data'][1]['relationships']['chip']).to be_present
      expect(json['data'][1]['relationships']['chip']['data']['type']).to eq "chips"
      expect(json['data'][1]['relationships']['chip']['data']['id']).to eq chip2.id.to_s
    end



  end

  context '#create' do
    let(:body) do
      {
        data: {
          type: "runs",
          attributes: {
            runs: [
              attributes_for(:run)
            ]
          }
        }
      }.to_json
    end

    context 'on success' do
      it 'has a created status' do
        post v1_runs_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a run' do
        expect { post v1_runs_path, params: body, headers: json_api_headers }.to change { Run.count }.by(1)
      end

      it 'creates a run with the correct attributes' do
        post v1_runs_path, params: body, headers: json_api_headers
        run = Run.first
        expect(run.name).to be_present
        expect(run.state).to be_present
        expect(run.chip).to be_nil
      end

    end

  end

  context '#update' do
    let(:run) { create(:run, chip: create(:chip_with_flowcells)) }

    context 'on success' do
      let(:body) do
        {
          data: {
            type: "runs",
            id: run.id,
            attributes: {
              state: "started",
              name: "aname"
            }
          }
        }.to_json
      end

      it 'has a ok status' do
        patch v1_run_path(run), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates a run' do
        patch v1_run_path(run), params: body, headers: json_api_headers
        run.reload
        expect(run.state).to eq "started"
        expect(run.name).to eq "aname"
      end

      it 'sends a message to the warehouse' do
        expect(Messages).to receive(:publish)
        patch v1_run_path(run), params: body, headers: json_api_headers
      end

      it 'returns the correct attributes' do
        patch v1_run_path(run), params: body, headers: json_api_headers
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['id']).to eq run.id.to_s
      end

    end

    context 'on failure' do
      let(:body) do
        {
          data: {
            type: "runs",
            id: 123,
            attributes: {
              state: "started",
              name: "aname"
            }
          }
        }.to_json
      end

      it 'has a ok unprocessable_entity' do
        patch v1_run_path(123), params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not update a run' do
        patch v1_run_path(123), params: body, headers: json_api_headers
        run.reload
        expect(run).to be_pending
      end

      it 'has an error message' do
        patch v1_run_path(123), params: body, headers: json_api_headers
        expect(JSON.parse(response.body)["data"]).to include("errors" => "Couldn't find Run with 'id'=123")
      end
    end

  end

  context '#show' do
    let!(:run) { create(:run, state: 'pending') }
    let!(:chip) { create(:chip_with_flowcells, run: run) }
    let(:library1) { create(:library, flowcell: chip.flowcells[0]) }
    let(:library2) { create(:library, flowcell: chip.flowcells[1]) }

    it 'returns the runs' do
      get v1_run_path(run), headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['id']).to eq(run.id.to_s)
    end

    it 'returns the correct attributes' do
      get v1_run_path(run), headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data']['id']).to eq(run.id.to_s)
      expect(json['data']['attributes']['state']).to eq(run.state)
      expect(json['data']['attributes']['chip_barcode']).to eq(run.chip.barcode)
    end

    it 'returns the correct relationships' do
      get "#{v1_run_path(run)}?include=chip.flowcells.library", headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['relationships']['chip']).to be_present
      expect(json['data']['relationships']['chip']['data']['type']).to eq "chips"
      expect(json['data']['relationships']['chip']['data']['id']).to eq chip.id.to_s
    end

    it 'returns the correct includes' do
      chip.reload
      get "#{v1_run_path(run)}?include=chip.flowcells.library", headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['included'][0]['id']).to eq chip.id.to_s
      expect(json['included'][0]['type']).to eq "chips"
      expect(json['included'][0]['attributes']['barcode']).to eq chip.barcode
      expect(json['included'][0]['relationships']['flowcells']['data'][0]['id']).to eq chip.flowcells[0].id.to_s
      expect(json['included'][0]['relationships']['flowcells']['data'][1]['id']).to eq chip.flowcells[1].id.to_s

      expect(json['included'][1]['id']).to eq chip.flowcells[0].id.to_s
      expect(json['included'][1]['type']).to eq "flowcells"
      expect(json['included'][1]['attributes']['position']).to eq chip.flowcells[0].position
      expect(json['included'][1]['relationships']['library']).to be_present

      expect(json['included'][2]['id']).to eq chip.flowcells[1].id.to_s
      expect(json['included'][2]['type']).to eq "flowcells"
      expect(json['included'][2]['attributes']['position']).to eq chip.flowcells[1].position
      expect(json['included'][2]['relationships']['library']).to be_present
    end

  end

  context '#destroy' do

    let(:run) { create(:run) }

    it 'has a status of ok' do
      delete v1_run_path(run), headers: json_api_headers
      expect(response).to have_http_status(:no_content)
    end

  end

end
