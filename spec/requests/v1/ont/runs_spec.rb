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

  describe 'index' do
    # let!(:run1) { create(:ont_run, instrument: gridion) }
    # let!(:run2) { create(:ont_run, instrument: promethion) }

    before do
      get v1_ont_runs_path, headers: json_api_headers
    end

    it 'returns a response' do
      expect(response).to have_http_status(:success)
    end
  end
end
