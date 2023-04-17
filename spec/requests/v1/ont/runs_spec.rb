# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RunsController' do
  def json
    ActiveSupport::JSON.decode(response.body)
  end

  before do
    create(:ont_min_know_version_default, name: 'v22')
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

      it 'publishes the message' do
        expect(Messages).to receive(:publish).with(instance_of(Ont::Run), having_attributes(pipeline: 'ont'))
        post v1_ont_runs_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:success), response.body
      end
    end

    context 'on failure' do
      let(:instrument) { create(:ont_minion) }
      let(:pool1) { create(:ont_pool) }
      let(:pool2) { create(:ont_pool) }
      let(:attr1) { { flowcell_id: 'F1', position: 1, ont_pool_id: pool1.id } }
      let(:attr2) { { flowcell_id: 'F2', position: 1, ont_pool_id: pool1.id } }
      let(:body) do
        {
          data: {
            type: 'runs',
            attributes: {
              ont_instrument_id: instrument.id,
              state: 'completed',
              flowcell_attributes: [attr1, attr2]
            }
          }
        }.to_json
      end

      before do
        post v1_ont_runs_path, params: body, headers: json_api_headers
      end

      it 'returns an error response' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns failure response' do
        titles = json['errors'].pluck('title')
        expect(titles).to include 'number of flowcells must be less than instrument max number'
      end

      it 'does not publish the message' do
        expect(Messages).not_to receive(:publish).with(instance_of(Ont::Run), having_attributes(pipeline: 'ont'))
        post v1_ont_runs_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity), response.body
      end
    end
  end

  describe 'update flowcells' do
    context 'on success' do
      # When we update a run successfuly, we are able to keep, change, add, and remove flowcells at once.

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

      context 'messages' do
        let(:run) { create(:ont_gridion_run, flowcell_count: 3) }

        let(:body) do
          {
            data: {
              type: 'runs',
              id: run.id,
              attributes: {
                ont_instrument_id: run.ont_instrument_id,
                state: 'completed'
              }
            }
          }.to_json
        end

        it 'will be published' do
          expect(Messages).to receive(:publish).with(instance_of(Ont::Run), having_attributes(pipeline: 'ont'))
          patch "#{v1_ont_runs_path}/#{run.id}", params: body, headers: json_api_headers
          expect(response).to have_http_status(:success), response.body
        end
      end
    end

    context 'on failure' do
      let(:run) { create(:ont_gridion_run, flowcell_count: 2) }
      let(:fc1) { run.flowcells.find_by(position: 1) }
      let(:fc2) { run.flowcells.find_by(position: 2) }
      let(:attr1) { { id: fc1.id, flowcell_id: fc1.flowcell_id, position: fc1.position, ont_pool_id: fc1.ont_pool_id } }
      # Give the same attributes to the second flowcell for the update
      let(:attr2) { { id: fc2.id, flowcell_id: fc1.flowcell_id, position: fc2.position, ont_pool_id: fc1.ont_pool_id } }
      let(:body) do
        {
          data: {
            type: 'runs',
            id: run.id,
            attributes: {
              ont_instrument_id: run.ont_instrument_id,
              state: 'pending',
              flowcell_attributes: [attr1, attr2]
            }
          }
        }.to_json
      end

      before do
        patch "#{v1_ont_runs_path}/#{run.id}", params: body, headers: json_api_headers
      end

      it 'returns an error response' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a run' do
        expect do
          patch "#{v1_ont_runs_path}/#{run.id}", params: body, headers: json_api_headers
        end.not_to change(Ont::Run, :count)
      end

      it 'returns error messages' do
        errors = json['errors']
        titles = errors.pluck('title')
        expect(titles).to include "flowcell_id #{fc1.flowcell_id} at position #{fc2.position_name} is duplicated in the same run"
      end

      context 'messages' do
        let(:run) { create(:ont_gridion_run, flowcell_count: 3) }

        let(:body) do
          {
            data: {
              type: 'runs',
              id: run.id,
              attributes: {
                ont_instrument_id: nil,
                state: 'completed'
              }
            }
          }.to_json
        end

        it 'will not be published' do
          expect(Messages).not_to receive(:publish).with(instance_of(Ont::Run), having_attributes(pipeline: 'ont'))
          patch "#{v1_ont_runs_path}/#{run.id}", params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity), response.body
        end
      end
    end
  end

  context 'with uniqueness validations' do
    context 'create' do
      let!(:existing_flowcell) { create(:ont_flowcell) }
      let(:instrument) { create(:ont_gridion) }
      let(:pool1) { create(:ont_pool) }
      let(:pool2) { create(:ont_pool) }
      let(:attr1) { { flowcell_id: existing_flowcell.flowcell_id, position: 1, ont_pool_id: pool1.id } }
      let(:attr2) { { flowcell_id: 'F2', position: 2, ont_pool_id: pool2.id } }
      let(:attr3) { { flowcell_id: 'F2', position: 2, ont_pool_id: pool2.id } }
      let(:body) do
        {
          data: {
            type: 'runs',
            attributes: {
              ont_instrument_id: instrument.id,
              state: 'pending',
              flowcell_attributes: [attr1, attr2, attr3]
            }
          }
        }.to_json
      end

      it 'returns errors' do
        post v1_ont_runs_path, params: body, headers: json_api_headers

        expect(response).to have_http_status(:unprocessable_entity), response.body

        titles = json['errors'].pluck('title')
        expect(titles).to include("position x#{attr2[:position]} is duplicated in the same run")
        expect(titles).to include("flowcell_id #{attr2[:flowcell_id]} at position x#{attr2[:position]} is duplicated in the same run")
      end
    end

    context 'update' do
      let!(:existing_flowcell) { create(:ont_flowcell) }
      let(:run) { create(:ont_gridion_run, flowcell_count: 5) }
      let(:fc1) { run.flowcells.find_by(position: 1) }
      let(:fc2) { run.flowcells.find_by(position: 2) }
      let(:fc3) { run.flowcells.find_by(position: 3) }
      let(:attr1) { { id: fc1.id, flowcell_id: existing_flowcell.flowcell_id, position: fc1.position, ont_pool_id: fc1.ont_pool_id } }
      let(:attr2) { { id: fc2.id, flowcell_id: fc1.flowcell_id, position: fc2.position, ont_pool_id: fc2.ont_pool_id }  }
      let(:attr3) { { id: fc3.id, flowcell_id: fc1.flowcell_id, position: fc2.position, ont_pool_id: fc2.ont_pool_id }  }
      let(:body) do
        {
          data: {
            type: 'runs',
            id: run.id,
            attributes: {
              ont_instrument_id: run.ont_instrument_id,
              state: 'completed',
              flowcell_attributes: [attr1, attr2, attr3]
            }
          }
        }.to_json
      end

      it 'returns errors' do
        patch "#{v1_ont_runs_path}/#{run.id}", params: body, headers: json_api_headers

        expect(response).to have_http_status(:unprocessable_entity), response.body

        titles = json['errors'].pluck('title')
        expect(titles).to include("flowcell_id #{attr3[:flowcell_id]} at position x#{attr3[:position]} is duplicated in the same run")
        expect(titles).to include("position x#{attr3[:position]} is duplicated in the same run")
      end
    end
  end

  context 'pagination' do
    let!(:runs) { create_list(:ont_gridion_run, 6).sort_by(&:created_at).reverse }

    before do
      get "#{v1_ont_runs_path}?page[number]=2&page[size]=2", headers: json_api_headers
    end

    it 'has a success status' do
      expect(response).to have_http_status(:success), response.body
    end

    it 'returns list of runs' do
      expect(json['data'].length).to eq(2)
    end

    it 'returns correct attributes' do
      expected_runs = runs.each_slice(2).to_a[1] # size: 2, page: 2

      expected_runs.each do |run|
        run_attributes = find_resource(id: run.id, type: 'runs')['attributes']
        expect(run_attributes).to include(
          'ont_instrument_id' => run.ont_instrument_id,
          'experiment_name' => run.experiment_name,
          'state' => run.state,
          'created_at' => run.created_at.to_fs(:us)
        )
      end
    end
  end
end
