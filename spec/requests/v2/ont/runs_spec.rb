# frozen_string_literal: true

require "rails_helper"

RSpec.describe 'GraphQL', type: :request do
  let(:run) { create(:ont_run) }
  let(:run_factory) { instance_double("Ont::RunFactory") }
  let(:message) { { key: 'value' } }

  before do
    allow(Ont::RunFactory).to receive(:new).and_return(run_factory)
    allow(Pipelines).to receive_message_chain(:ont, :covid, :message).and_return(message)
  end

  context 'create run' do
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
        .to match_array(run.flowcells.map { |fc| fc.position })

      expect(flowcell_json.map { |fc| fc['library']['name'] })
        .to match_array(run.flowcells.map { |fc| fc.library.name })
    end

    it 'sends a message to the warehouse for each request' do
      run.flowcells.each do |flowcell|
        expect(Messages).to receive(:publish).with(flowcell.library.requests, message).exactly(:once)
      end      

      allow(run_factory).to receive(:save).and_return(true)
      allow(run_factory).to receive(:run).and_return(run)

      post v2_path, params: { query: valid_query }
    end

    it 'responds with errors provided by the run factory' do
      errors = Class.new do
        def full_messages
          [ 'test error' ]
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
