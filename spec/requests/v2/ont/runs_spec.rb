# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphQL', type: :request do
  let(:run_factory) { instance_double('Ont::RunFactory') }

  before do
    allow(Ont::RunFactory).to receive(:new).and_return(run_factory)
  end

  context 'get run' do
    context 'when there is a valid run' do
      let!(:run) { create(:ont_run) }

      it 'returns the run with valid ID' do
        post v2_path, params: { query:
          "{ ontRun(id: #{run.id}) { id state deactivatedAt experimentName flowcells { id } } }" }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['ontRun']).to include(
          'id' => run.id.to_s, 'state' => run.state.to_s.upcase,
          'deactivatedAt' => run.deactivated_at,
          'experimentName' => run.experiment_name,
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
        { 'id' => run.id.to_s, 'state' => run.state.to_s.upcase,
          'deactivatedAt' => run.deactivated_at,
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
    let(:run) { create(:ont_run) }
    let(:run_factory) { instance_double('Ont::RunFactory') }
    let(:message) { { key: 'value' } }

    before do
      allow(Ont::RunFactory).to receive(:new).and_return(run_factory)
      allow(Pipelines).to receive_message_chain(:ont, :message).and_return(message)
    end

    def valid_query
      <<~GQL
        mutation {
          createOntRun( input: { flowcells: [] })
          { run { id state flowcells { position library { name } } } errors }
        }
      GQL
    end

    it 'creates a run with provided parameters' do
      allow(run_factory).to receive(:save).and_return(true)
      allow(run_factory).to receive(:run).and_return(run)

      post v2_path, params: { query: valid_query }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      mutation_json = json['data']['createOntRun']
      run_json = mutation_json['run']
      expect(run_json['id']).to eq(run.id.to_s)
      expect(run_json['state']).to eq(run.state.upcase)

      flowcell_json = run_json['flowcells']
      expect(flowcell_json.count).to eq(run.flowcells.count)
      expect(flowcell_json.map { |fc| fc['position'] })
        .to match_array(run.flowcells.map(&:position))

      expect(flowcell_json.map { |fc| fc['library']['name'] })
        .to match_array(run.flowcells.map { |fc| fc.library.name })
    end

    it 'sends a single message to the warehouse' do
      expect(Messages).to receive(:publish).with(run, message).exactly(:once)

      allow(run_factory).to receive(:save).and_return(true)
      allow(run_factory).to receive(:run).and_return(run)

      post v2_path, params: { query: valid_query }
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

      mutation_json = json['data']['createOntRun']
      expect(mutation_json['run']).to be_nil
      expect(mutation_json['errors']).to contain_exactly('test error')
    end

    def missing_required_fields_query
      'mutation { createOntRun(input: { flowcells: { bogus: "data" } } ) { run { id } } }'
    end

    it 'provides an error when missing required fields' do
      post v2_path, params: { query: missing_required_fields_query }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['errors']).not_to be_empty
    end
  end

  context 'update run' do
    let(:run) { create(:ont_run) }
    let(:message) { { key: 'value' } }

    def valid_query
      <<~GQL
        mutation ($id: ID!, $state: RunStateEnum, $flowcells: [FlowcellInput!]) {
          updateOntRun( input: { id: $id properties: { state: $state, flowcells: $flowcells } } )
          { run { id state flowcells { position library { name } } } errors }
        }
      GQL
    end

    before do
      allow(Pipelines).to receive_message_chain(:ont, :message).and_return(message)
    end

    context 'invalid id' do
      let(:variables) { ActiveSupport::JSON.encode({ id: 10, state: nil, flowcells: nil }) }

      it 'gives no run back' do
        post v2_path, params: { query: valid_query, variables: variables }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)

        mutation_json = json['data']['updateOntRun']
        expect(mutation_json['run']).to be_nil
      end

      it 'generates an error' do
        post v2_path, params: { query: valid_query, variables: variables }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)

        mutation_json = json['data']['updateOntRun']
        expect(mutation_json['errors'].count).to be(1)
      end

      it 'does not send any messages to the warehouse' do
        expect(Messages).to_not receive(:publish)

        post v2_path, params: { query: valid_query, variables: variables }
      end
    end

    context 'no properties' do
      let(:variables) { ActiveSupport::JSON.encode({ id: run.id, state: nil, flowcells: nil }) }

      it 'returns the run unmodified' do
        expect(Ont::RunFactory).to_not receive(:new)

        post v2_path, params: { query: valid_query, variables: variables }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)

        run.reload # Must reload to see the updated values

        mutation_json = json['data']['updateOntRun']
        expect(mutation_json['errors']).to be_empty
        run_json = mutation_json['run']

        expect(run_json['id']).to eq(run.id.to_s)
        expect(run_json['state']).to eq(run.state.upcase)
      end

      it 'does not send any messages to the warehouse' do
        expect(Messages).to_not receive(:publish)

        post v2_path, params: { query: valid_query, variables: variables }
      end
    end

    context 'updated state' do
      let(:variables) do
        ActiveSupport::JSON.encode({ id: run.id, state: 'STARTED', flowcells: nil })
      end

      it 'updates the state on the existing run' do
        expect(run.state).to eq(:pending.to_s)
        expect(Ont::RunFactory).to_not receive(:new)

        post v2_path, params: { query: valid_query, variables: variables }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)

        run.reload # Must reload to see the updated values

        mutation_json = json['data']['updateOntRun']
        expect(mutation_json['errors']).to be_empty
        run_json = mutation_json['run']

        expect(run_json['id']).to eq(run.id.to_s)
        expect(run_json['state']).to eq(:started.to_s.upcase)
        expect(run.state).to eq(:started.to_s)
      end

      it 'sends a message to the warehouse for each request' do
        expect(Messages).to receive(:publish).with(run, message).exactly(:once)

        allow(run_factory).to receive(:save).and_return(true)
        allow(run_factory).to receive(:run).and_return(run)

        post v2_path, params: { query: valid_query, variables: variables }
      end
    end

    context 'updated flowcells' do
      context 'null array' do
        let(:variables) do
          ActiveSupport::JSON.encode({ id: run.id, state: 'PENDING', flowcells: nil })
        end

        it "doesn't update flowcells" do
          expect(Ont::RunFactory).to_not receive(:new)
          expect(run_factory).to_not receive(:save)

          post v2_path, params: { query: valid_query, variables: variables }
          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)

          mutation_json = json['data']['updateOntRun']
          expect(mutation_json['errors']).to be_empty
          expect(mutation_json['run']).to be
        end
      end

      context 'empty array' do
        let(:variables) { ActiveSupport::JSON.encode({ id: run.id, state: nil, flowcells: [] }) }

        it 'presents an error' do
          expect(Ont::RunFactory).to_not receive(:new)
          expect(run_factory).to_not receive(:save)

          post v2_path, params: { query: valid_query, variables: variables }
          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)

          mutation_json = json['data']['updateOntRun']
          expect(mutation_json['errors'].count).to be(1)
          expect(mutation_json['run']).to be_nil
        end

        it 'does not send any messages to the warehouse' do
          expect(Messages).to_not receive(:publish)

          post v2_path, params: { query: valid_query, variables: variables }
        end
      end

      context 'one flowcell' do
        let(:library) { create(:ont_library) }
        let(:variables) do
          ActiveSupport::JSON.encode({ id: run.id, state: nil, flowcells: [
            { 'position' => 4, libraryName: library.name }
          ] })
        end

        describe 'with a valid factory build' do
          it 'sends the flowcells and run to RunFactory' do
            allow(run_factory).to receive(:save).and_return(true)
            expect(Ont::RunFactory).to receive(:new).with(kind_of(Array), run)
            expect(run_factory).to receive(:save)

            post v2_path, params: { query: valid_query, variables: variables }
            expect(response).to have_http_status(:success)
            json = ActiveSupport::JSON.decode(response.body)

            mutation_json = json['data']['updateOntRun']
            expect(mutation_json['errors']).to be_empty
            expect(mutation_json['run']).to be

            expect(mutation_json['run']['id']).to eq(run.id.to_s)
          end

          it 'sends a message to the warehouse for each request' do
            expect(Messages).to receive(:publish).with(run, message).exactly(:once)

            allow(run_factory).to receive(:save).and_return(true)
            allow(run_factory).to receive(:run).and_return(run)

            post v2_path, params: { query: valid_query, variables: variables }
          end
        end

        describe 'with an invalid factory build' do
          let(:errors) do
            Class.new do
              def full_messages
                ['test error']
              end
            end.new
          end

          before do
            allow(run_factory).to receive(:save).and_return(false)
            allow(run_factory).to receive(:errors).and_return(errors)
          end

          it 'reports errors and returns no run' do
            expect(Ont::RunFactory).to receive(:new).with(kind_of(Array), run)

            post v2_path, params: { query: valid_query, variables: variables }
            expect(response).to have_http_status(:success)
            json = ActiveSupport::JSON.decode(response.body)

            mutation_json = json['data']['updateOntRun']
            expect(mutation_json['errors']).to contain_exactly('test error')
            expect(mutation_json['run']).to be_nil
          end

          it 'does not send any messages to the warehouse' do
            expect(Messages).to_not receive(:publish)

            post v2_path, params: { query: valid_query, variables: variables }
          end
        end
      end
    end
  end
end
