# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RunsController' do
  def json
    ActiveSupport::JSON.decode(response.body)
  end

  before do
    Flipper.enable(:dpl_281_ont_create_sequencing_runs)
  end

  describe 'index' do
    before do
      get v1_ont_runs_path, headers: json_api_headers
    end

    it 'returns a response' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'create' do
    context 'on success' do
      let(:instrument) { create(:ont_gridion) }
      let(:pool1) { create(:ont_pool) }
      let(:pool2) { create(:ont_pool) }
      let(:attr1) { { flowcell_id: 'F1', position: 1, ont_pool_id: pool1.id } }
      let(:attr2) { { flowcell_id: 'F2', position: 2, ont_pool_id: pool2.id } }
      let(:body) do
        {
          data: {
            type: 'runs',
            attributes: {
              ont_instrument_id: instrument.id,
              state: 'pending',
              flowcell_attributes: [attr1, attr2]
            }
          }
        }.to_json
      end

      it 'creates a run' do
        post v1_ont_runs_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created)

        expect(Ont::Run.count).to eq(1)
        run = Ont::Run.last
        fc1 = run.flowcells.find_by(position: 1)
        expect(fc1).to be_truthy
        expect(fc1.flowcell_id).to eq(attr1[:flowcell_id])
        expect(fc1.position).to eq(attr1[:position])
        expect(fc1.pool.id).to eq(attr1[:ont_pool_id])

        fc2 = run.flowcells.find_by(position: 2)
        expect(fc2).to be_truthy
        expect(fc2.flowcell_id).to eq(attr2[:flowcell_id])
        expect(fc2.position).to eq(attr2[:position])
        expect(fc2.pool.id).to eq(attr2[:ont_pool_id])
      end
    end
  end

  describe 'update flowcells' do
    context 'on success' do
      # We we update a run successfuly, we are able to keep, change, add, and remove flowcells at once.

      let(:run) { create(:ont_gridion_run, flowcell_count: 3) }

      # Existing flowcells on the run
      let(:fc1) { run.flowcells.find_by(position: 1) } # to keep
      let(:fc2) { run.flowcells.find_by(position: 2) } # to change
      let(:fc3) { run.flowcells.find_by(position: 3) } # to remove

      # Create one pool for changing and another for adding a flowcell.
      let(:pool2) { create(:ont_pool) } # for changing
      let(:pool4) { create(:ont_pool) } # for adding

      # Flowcell attributes of the run in payload.
      # To keep a flowcell, we include id and existing attributes (attr1)
      # To change a flowcell, we include id and modified attributes (attr2)
      # To remove a flowcell, we exclude it from the list (no attr3)
      # To add a flowcell, we include attributes; id will be assigned to it (attr4)
      let(:attr1) { { id: fc1.id, flowcell_id: fc1.flowcell_id, position: fc1.position, ont_pool_id: fc1.ont_pool_id } }
      let(:attr2) { { id: fc2.id, flowcell_id: "#{fc2.flowcell_id}UPDATED", position: fc2.position, ont_pool_id: pool2.id } }
      let(:attr4) { { flowcell_id: 'F4', position: 4, ont_pool_id: pool4.id } }

      let(:body) do
        {
          data: {
            type: 'runs',
            id: run.id,
            attributes: {
              ont_instrument_id: run.ont_instrument_id,
              state: 'pending',
              flowcell_attributes: [attr1, attr2, attr4]
            }
          }
        }.to_json
      end

      before do
        patch "#{v1_ont_runs_path}/#{run.id}", params: body, headers: json_api_headers
      end

      it 'returns success response' do
        expect(response).to have_http_status(:success)
      end

      it 'keeps flowcell' do
        expect(run.flowcells.length).to eq(3)
        fc1 = run.flowcells.find_by(position: 1)
        expect(fc1).to be_truthy
        expect(fc1.id).to eq(attr1[:id])
        expect(fc1.flowcell_id).to eq(attr1[:flowcell_id])
        expect(fc1.position).to eq(attr1[:position])
        expect(fc1.ont_pool_id).to eq(attr1[:ont_pool_id])
      end

      it 'changes flowcell' do
        expect(run.flowcells.length).to eq(3)
        fc2 = run.flowcells.find_by(position: 2)
        expect(fc1).to be_truthy
        expect(fc2.id).to eq(attr2[:id])
        expect(fc2.flowcell_id).to eq(attr2[:flowcell_id])
        expect(fc2.position).to eq(attr2[:position])
        expect(fc2.ont_pool_id).to eq(attr2[:ont_pool_id])
      end

      it 'removes flowcell' do
        fc3 = run.flowcells.find_by(position: 3)
        expect(run.flowcells.length).to eq(3) # We removed fc3 but added fc4.
        expect(fc3).not_to be_truthy
      end

      it 'adds flowcell' do
        fc4 = run.flowcells.find_by(position: 4)
        expect(run.flowcells.length).to eq(3)
        expect(fc4).to be_truthy
        expect(fc4.flowcell_id).to eq(attr4[:flowcell_id])
        expect(fc4.position).to eq(attr4[:position])
        expect(fc4.ont_pool_id).to eq(attr4[:ont_pool_id])
      end
    end
  end
end
