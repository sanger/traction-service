# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PlatesController' do
  before do
    # Create a default smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v10', default: true)
  end

  describe '#get' do
    let!(:run1) { create(:pacbio_run) }
    let!(:run2) { create(:pacbio_run) }
    let!(:plate1) { create(:pacbio_plate, run: run1) }
    let!(:plate2) { create(:pacbio_plate, run: run2) }
    let!(:wells) { create_list(:pacbio_well, 5, plate: plate2) }

    it 'returns a list of plates' do
      get v1_pacbio_runs_plates_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get "#{v1_pacbio_runs_plates_path}?include=wells", headers: json_api_headers

      expect(response).to have_http_status(:success), response.body
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['attributes']['pacbio_run_id']).to eq(plate1.pacbio_run_id)
      expect(json['data'][1]['attributes']['pacbio_run_id']).to eq(plate2.pacbio_run_id)

      wells = json['included']
      expect(wells.length).to eq(7)

      well = wells[0]['attributes']
      plate_well = plate1.wells.first
      expect(well['on_plate_loading_concentration']).to eq(plate_well.on_plate_loading_concentration)
    end
  end
end
