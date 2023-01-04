# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RunsController' do
  def json
    ActiveSupport::JSON.decode(response.body)
  end

  before do
    Flipper.enable(:dpl_281_ont_create_sequencing_runs)
  end

  # let!(:minion) { create(:ont_minion) }
  # let!(:gridion) { create(:ont_gridion) }
  # let!(:promethion) { create(:ont_promethion) }
  # let!(:run1) { create(:ont_run_with_flowcells, instrument: gridion) }
  # let!(:run2) { create(:ont_run_with_flowcells, instrument: promethion) }

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
                ont_pool_id: 1
              }]
            }
          }
        }.to_json
      end

      it 'creates a run' do
        post v1_ont_runs_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created)
      end
    end
  end
end
