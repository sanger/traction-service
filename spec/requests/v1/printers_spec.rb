# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PrintersController' do
  describe '#index' do
    let!(:tube_printer) { create(:printer, labware_type: 'tube') }
    let!(:deactivated_tube_printer) { create(:printer, labware_type: 'tube', deactivated_at: Time.current) }
    let!(:plate_printer) { create(:printer, labware_type: 'plate96') }

    it 'returns a list of printers' do
      get v1_printers_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(3)

      expect(json['data'][0]['attributes']['name']).to eq(tube_printer.name)
      expect(json['data'][0]['attributes']['active?']).to eq(tube_printer.active?)
      expect(json['data'][0]['attributes']['labware_type']).to eq(tube_printer.labware_type)

      expect(json['data'][1]['attributes']['name']).to eq(deactivated_tube_printer.name)
      expect(json['data'][1]['attributes']['active?']).to eq(deactivated_tube_printer.active?)
      expect(json['data'][1]['attributes']['labware_type']).to eq(deactivated_tube_printer.labware_type)

      expect(json['data'][2]['attributes']['name']).to eq(plate_printer.name)
      expect(json['data'][2]['attributes']['active?']).to eq(plate_printer.active?)
      expect(json['data'][2]['attributes']['labware_type']).to eq(plate_printer.labware_type)
    end

    it 'filters by name' do
      get v1_printers_path(filter: { name: plate_printer.name }), headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(1)

      expect(json['data'][0]['attributes']['name']).to eq(plate_printer.name)
    end

    it 'filters by labware_type' do
      get v1_printers_path(filter: { labware_type: 'tube' }), headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
      expect(json['data'][0]['attributes']['name']).to eq(tube_printer.name)
      expect(json['data'][1]['attributes']['name']).to eq(deactivated_tube_printer.name)

      get v1_printers_path(filter: { labware_type: 'plate96' }), headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(1)
      expect(json['data'][0]['attributes']['name']).to eq(plate_printer.name)
    end

    it 'returns a 400 if the labware_type filter is invalid' do
      get v1_printers_path(filter: { labware_type: 'invalid' }), headers: json_api_headers
      expect(response).to have_http_status(:bad_request)
    end

    it 'filters by active' do
      get v1_printers_path(filter: { active: 'true' }), headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
      expect(json['data'][0]['attributes']['name']).to eq(tube_printer.name)
      expect(json['data'][1]['attributes']['name']).to eq(plate_printer.name)

      get v1_printers_path(filter: { active: 'false' }), headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(1)
      expect(json['data'][0]['attributes']['name']).to eq(deactivated_tube_printer.name)
    end
  end

  describe '#show' do
    let!(:printer) { create(:printer) }

    it 'returns a printer' do
      get v1_printer_path(printer), headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['id']).to eq(printer.id.to_s)
      expect(json['data']['attributes']['name']).to eq(printer.name)
      expect(json['data']['attributes']['active?']).to eq(printer.active?)
      expect(json['data']['attributes']['labware_type']).to eq(printer.labware_type)
    end

    it 'returns a 404 if the printer does not exist' do
      get v1_printer_path(id: 0), headers: json_api_headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
