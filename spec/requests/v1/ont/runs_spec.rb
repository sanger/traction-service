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
      let(:instrument) { create(:ont_instrument) }
      let(:pool) { create(:ont_pool) }
      let(:body) do
        {
          data: {
            type: 'runs',
            attributes: {
              ont_instrument_id: instrument.id,
              state: 'pending',
              flowcell_attributes: [{
                flowcell_id: 'F1',
                position: 1,
                ont_pool_id: pool.id
              }]
            }
          }
        }.to_json
      end

      it 'creates a run' do
        post v1_ont_runs_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created)
        # p Ont::Run.last
        # p Ont::Run.last.flowcells
      end
    end
  end

  describe 'update flowcells' do
    context 'on success' do
      let(:run) { create(:ont_gridion_run, flowcell_count: 3) }

      # Existing flowcells on the run
      let(:fc1) { run.flowcells[0] } # to keep
      let(:fc2) { run.flowcells[1] } # to change
      let(:fc3) { run.flowcells[2] } # to remove

      # Create pools
      let(:pool2) { create(:ont_pool) } # for updating
      let(:pool4) { create(:ont_pool) } # for adding

      let(:attr1) { { id: fc1.id, flowcell_id: fc1.flowcell_id, position: fc1.position, ont_pool_id: fc1.ont_pool_id } }
      let(:attr2) { { id: fc2.id, flowcell_id: "#{fc2.flowcell_id}UPDATED", position: fc2.position, ont_pool_id: pool2.id } }
      let(:attr4) { { flowcell_id: 'F4', position: 4, ont_pool_id: pool4.id } }
      let(:flowcell_attributes) { [attr1, attr2, attr4] }

      let(:body) do
        {
          data: {
            type: 'runs',
            id: run.id,
            attributes: {
              ont_instrument_id: run.ont_instrument_id,
              state: 'pending',
              flowcell_attributes:
            }
          }
        }.to_json
      end

      before do
        # binding.pry
        patch "#{v1_ont_runs_path}/#{run.id}", params: body, headers: json_api_headers
        run.reload
        run.flowcells.reload
      end

      it 'returns success response' do
        expect(response).to have_http_status(:success)
      end

      it 'keeps flowcell' do
        expect(run.flowcells.length).to eq(3)
        expect(run.flowcells).to include(fc1)
        expect(fc1.flowcell_id).to eq(attr1[:flowcell_id])
        expect(fc1.position).to eq(attr1[:position])
        expect(fc1.ont_pool_id).to eq(attr1[:ont_pool_id])
      end

      it 'changes flowcell' do
        fc2 = run.flowcells.select { |fc| fc.position == 2 }.first
        expect(run.flowcells.length).to eq(3)
        expect(run.flowcells).to include(fc2)
        expect(fc2.flowcell_id).to eq(attr2[:flowcell_id])
        expect(fc2.position).to eq(attr2[:position])
        expect(fc2.ont_pool_id).to eq(attr2[:ont_pool_id])
      end

      it 'removes flowcell' do
        expect(run.flowcells.length).to eq(3)
        fc3 = run.flowcells.select { |fc| fc.position == 3 }.first
        expect(fc3).to be_nil
      end

      it 'adds flowcell' do
        fc4 = run.flowcells.select { |fc| fc.position == 4 }.first
        expect(run.flowcells.length).to eq(3)
        expect(fc4.flowcell_id).to eq(attr4[:flowcell_id])
        expect(fc4.position).to eq(attr4[:position])
        expect(fc4.ont_pool_id).to eq(attr4[:ont_pool_id])
      end
    end
  end
end
