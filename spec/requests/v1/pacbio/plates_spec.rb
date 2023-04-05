# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PlatesController' do
  describe '#get' do
    let!(:pacbio_plates) { create_list(:plate_with_wells_and_requests, 5, pipeline: 'pacbio') }

    it 'returns a list of plates' do
      get v1_pacbio_plates_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(5)
    end

    it 'returns the correct attributes' do
      get v1_pacbio_plates_path, headers: json_api_headers

      expect(response).to have_http_status(:success)

      pacbio_plates.each do |plate|
        plate_attributes = find_resource(type: 'plates', id: plate.id)['attributes']
        expect(plate_attributes).to include(
          'barcode' => plate.barcode,
          'created_at' => plate.created_at.to_fs(:us)
        )
      end
    end

    it 'returns the correct relationships' do
      get "#{v1_pacbio_plates_path}?include=wells.materials", headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['relationships']['wells']).to be_present

      well = json['included'].find { |well| well['type'] == 'wells' }
      expect(well['type']).to eq('wells')
      expect(well['id']).to eq(pacbio_plates.first.wells.first.id.to_s)
      expect(well['attributes']['position']).to eq(pacbio_plates.first.wells.first.position)

      materials = json['included'].select { |resource| resource['type'] == 'container_materials' }

      expect(materials.length).to eq(15)
      materials = materials.index_by { |mat| mat['id'].to_i }

      pacbio_plates.flat_map(&:wells).flat_map(&:materials).each do |request|
        material = materials.fetch(request.container_material.id)

        expect(material['id']).to eq(request.container_material.id.to_s)
        expect(material['attributes']['library_type']).to eq(request.library_type)
        expect(material['attributes']['estimate_of_gb_required']).to eq(request.estimate_of_gb_required)
        expect(material['attributes']['number_of_smrt_cells']).to eq(request.number_of_smrt_cells)
        expect(material['attributes']['cost_code']).to eq(request.cost_code)
        expect(material['attributes']['external_study_id']).to eq(request.external_study_id)
        expect(material['attributes']['sample_name']).to eq(request.sample_name)
        expect(material['attributes']['sample_species']).to eq(request.sample_species)
        expect(material['attributes']['material_type']).to eq('request')
      end
    end

    it 'returns the correct relationships with requests' do
      get "#{v1_pacbio_plates_path}?include=wells.requests", headers: json_api_headers

      expect(response).to have_http_status(:success), response.body
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['relationships']['wells']).to be_present

      well = json['included'].find { |well| well['type'] == 'wells' }
      expect(well['type']).to eq('wells')
      expect(well['id']).to eq(pacbio_plates.first.wells.first.id.to_s)
      expect(well['attributes']['position']).to eq(pacbio_plates.first.wells.first.position)

      requests = json['included'].select { |resource| resource['type'] == 'requests' }

      expect(requests.length).to eq(15)
      requests = requests.index_by { |request| request['id'].to_i }

      pacbio_plates.flat_map(&:wells).flat_map(&:pacbio_requests).each do |request|
        request_data = requests.fetch(request.id)

        expect(request_data['id']).to eq(request.id.to_s)
        expect(request_data['attributes']['library_type']).to eq(request.library_type)
        expect(request_data['attributes']['estimate_of_gb_required']).to eq(request.estimate_of_gb_required)
        expect(request_data['attributes']['number_of_smrt_cells']).to eq(request.number_of_smrt_cells)
        expect(request_data['attributes']['cost_code']).to eq(request.cost_code)
        expect(request_data['attributes']['external_study_id']).to eq(request.external_study_id)
        expect(request_data['attributes']['sample_name']).to eq(request.sample_name)
        expect(request_data['attributes']['sample_species']).to eq(request.sample_species)
      end
    end

    context 'pagination' do
      let!(:expected_plates) { create_list(:plate_with_wells_and_requests, 5, pipeline: 'pacbio', created_at: Time.zone.now + 10) }

      before do
        # There should be 10 plates total so we get the 5 we just created
        get "#{v1_pacbio_plates_path}?page[number]=1&page[size]=5",
            headers: json_api_headers
      end

      it 'has a success status' do
        expect(response).to have_http_status(:success), response.body
      end

      it 'returns a list of plates' do
        expect(json['data'].length).to eq(5)
      end

      it 'returns the correct attributes', aggregate_failures: true do
        expected_plates.each do |plate|
          plate_attributes = find_resource(type: 'plates', id: plate.id)['attributes']
          expect(plate_attributes).to include(
            'barcode' => plate.barcode,
            'created_at' => plate.created_at.to_fs(:us)
          )
        end
      end

      it 'filtering by barcodes' do
        barcodes = pacbio_plates.pluck(:barcode)[0..1]
        get "#{v1_pacbio_plates_path}?filter[barcode]=#{barcodes.join(',')}",
            headers: json_api_headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'].length).to eq(barcodes.length)
        expect(json['data'][0]['attributes']['barcode']).to eq barcodes[0]
        expect(json['data'][1]['attributes']['barcode']).to eq barcodes[1]
      end
    end
  end
end
