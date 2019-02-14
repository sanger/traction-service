require "rails_helper"

RSpec.describe 'RunsController', type: :request do

  let(:headers) do
    {
      'Content-Type' => 'application/vnd.api+json',
      'Accept' => 'application/vnd.api+json'
    }
  end

  context '#get' do
    let!(:run1) { create(:run, state: 'pending') }
    let!(:run2) { create(:run, state: 'started') }
    let!(:chip1) { create(:chip, run: run1) }
    let!(:chip2) { create(:chip, run: run2) }

    it 'returns a list of runs' do
      get v1_runs_path, headers: headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'only returns active runs' do
      run3 = create(:run, deactivated_at: DateTime.now)
      get v1_runs_path, headers: headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get v1_runs_path, headers: headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'][0]['attributes']['state']).to eq(run1.state)
      expect(json['data'][0]['attributes']['chip-barcode']).to eq(run1.chip.barcode)
      expect(json['data'][1]['attributes']['state']).to eq(run2.state)
      expect(json['data'][1]['attributes']['chip-barcode']).to eq(run2.chip.barcode)
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
        post v1_runs_path, params: body, headers: headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a run' do
        expect { post v1_runs_path, params: body, headers: headers }.to change { Run.count }.by(1)
      end

      it 'creates a run with a chip' do
        post v1_runs_path, params: body, headers: headers
        expect(Run.last.chip).to be_present
        chip_id = Run.last.chip.id
        expect(Chip.find(chip_id).run).to eq Run.last
      end

      it 'creates a run with a chip with two flowcells' do
        post v1_runs_path, params: body, headers: headers
        expect(Run.last.chip.flowcells.length).to eq 2
        chip = Run.last.chip
        flowcells = chip.flowcells

        expect(Flowcell.find(flowcells[0].id).position).to eq(1)
        expect(Flowcell.find(flowcells[0].id).chip).to eq(chip)
        expect(Flowcell.find(flowcells[1].id).position).to eq(2)
        expect(Flowcell.find(flowcells[1].id).chip).to eq(chip)
      end

    end

  end

  context '#update' do
    let(:run) { create(:run) }

    context 'on success' do
      let(:body) do
        {
          data: {
            type: "runs",
            id: run.id,
            attributes: {
              "state":"started"
            }
          }
        }.to_json
      end

      it 'has a ok status' do
        patch v1_run_path(run), params: body, headers: headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates a run' do
        patch v1_run_path(run), params: body, headers: headers
        run.reload
        expect(run.state).to eq "started"
      end
    end

    context 'on failure' do
      let(:body) do
        {
          data: {
            type: "runs",
            id: 123,
            attributes: {
              "state":"started"
            }
          }
        }.to_json
      end

      it 'has a ok unprocessable_entity' do
        patch v1_run_path(123), params: body, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not update a run' do
        patch v1_run_path(123), params: body, headers: headers
        run.reload
        expect(run.state).to eq nil
      end

      it 'has an error message' do
        patch v1_run_path(123), params: body, headers: headers
        expect(JSON.parse(response.body)).to include("errors" => "Couldn't find Run with 'id'=123")
      end
    end
  end

  context '#show' do
    let!(:run) { create(:run, state: 'pending') }
    let!(:chip) { create(:chip, run: run) }
    let(:flowcell) { create(:flowcell, chip: chip) }
    let(:library) { create(:library, flowcell: flowcell) }

    it 'returns the runs' do
      get v1_run_path(run), headers: headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['id']).to eq(run.id.to_s)
    end

    it 'returns the correct attributes' do
      get v1_run_path(run), headers: headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['id']).to eq(run.id.to_s)
      expect(json['data']['attributes']['state']).to eq(run.state)
      expect(json['data']['attributes']['chip-barcode']).to eq(run.chip.barcode)
    end

    it 'returns the correct relationships' do
      get v1_run_path(run), headers: headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['relationships']['chip']).to be_present

      debugger
    end

  end

end
