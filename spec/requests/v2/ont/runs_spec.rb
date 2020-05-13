# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphQL', type: :request do
  context 'get run' do
    context 'when there is a valid run' do
      let!(:run) { create(:ont_run) }

      it 'returns the run with valid ID' do
        post v2_path, params: { query:
          "{ ontRun(id: #{run.id}) { id state deactivatedAt flowcells { id } } }" }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['ontRun']).to include(
          'id' => run.id.to_s, 'state' => run.state.to_s, 'deactivatedAt' => run.deactivated_at,
          'flowcells' => run.flowcells.map { |fc| { 'id' => fc.id.to_s } }
        )
      end

      it 'returns null when run invalid ID' do
        post v2_path, params: { query: '{ ontRun(id: 10) { id } }' }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['ontRun']).to be_nil
      end
    end
  end

  context 'get runs' do
    it 'returns empty array when no runs exist' do
      post v2_path, params: { query: '{ ontRuns { id } }' }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['ontRuns']).to be_empty
    end

    it 'returns single run when one exists' do
      run = create(:ont_run)
      post v2_path, params: { query:
        '{ ontRuns { id state deactivatedAt flowcells { id } } }' }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['ontRuns']).to contain_exactly(
        { 'id' => run.id.to_s, 'state' => run.state.to_s, 'deactivatedAt' => run.deactivated_at,
          'flowcells' => run.flowcells.map { |fc| { 'id' => fc.id.to_s } } }
      )
    end

    it 'returns all runs when many exist' do
      create_list(:ont_run, 3)
      post v2_path, params: { query: '{ ontRuns { id } }' }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['ontRuns'].length).to eq(3)
    end
  end

  context 'create run' do
    let(:run_factory) { instance_double('Ont::RunFactory') }

    before do
      allow(Ont::RunFactory).to receive(:new).and_return(run_factory)
    end

    def valid_query
      <<~GQL
        mutation {
          createCovidRun(
            input: {
              flowcells: []
            }
          ) {
            run { id state flowcells { position library { name } } }
            errors
          }
        }
      GQL
    end

    it 'creates a run with provided parameters' do
      run = create(:ont_run)

      allow(run_factory).to receive(:save).and_return(true)
      allow(run_factory).to receive(:run).and_return(run)

      post v2_path, params: { query: valid_query }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      mutation_json = json['data']['createCovidRun']
      run_json = mutation_json['run']
      expect(run_json['id']).to eq(run.id.to_s)
      expect(run_json['state']).to eq(run.state)

      flowcell_json = run_json['flowcells']
      expect(flowcell_json.count).to eq(run.flowcells.count)
      expect(flowcell_json.map { |fc| fc['position'] })
        .to match_array(run.flowcells.map(&:position))

      expect(flowcell_json.map { |fc| fc['library']['name'] })
        .to match_array(run.flowcells.map { |fc| fc.library.name })
    end

    it 'responds with errors provided by the run factory' do
      errors = Class.new do
        def full_messages
          ['test error']
        end
      end.new

      allow(run_factory).to receive(:save).and_return(false)
      allow(run_factory).to receive(:errors).and_return(errors)

      post v2_path, params: { query: valid_query }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      mutation_json = json['data']['createCovidRun']
      expect(mutation_json['run']).to be_nil
      expect(mutation_json['errors']).to contain_exactly('test error')
    end

    def missing_required_fields_query
      'mutation { createCovidRun(input: { flowcells: { bogus: "data" } } ) { run { id } } }'
    end

    it 'provides an error when missing required fields' do
      post v2_path, params: { query: missing_required_fields_query }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['errors']).not_to be_empty
    end
  end
end
