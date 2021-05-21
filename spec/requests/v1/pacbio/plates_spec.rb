require "rails_helper"

RSpec.describe 'PlatesController', type: :request do

  context '#get' do

    let!(:pacbio_plates) { create_list(:plate_with_wells_and_requests, 5, pipeline: 'pacbio')}
    let!(:other_plates) { create_list(:plate_with_wells_and_requests, 5, pipeline: 'ont')}

    it 'returns a list of plates' do
      get v1_pacbio_plates_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(5)
    end

    it 'returns the correct attributes' do
      get v1_pacbio_plates_path, headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['attributes']['barcode']).to eq(pacbio_plates.first.barcode)
      expect(json['data'][0]['attributes']['created_at']).to eq(pacbio_plates.first.created_at.to_s(:us))
    end

    it 'returns the correct relationships' do
      get "#{v1_pacbio_plates_path}?include=wells.materials", headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['relationships']['wells']).to be_present

      well = json['included'].find { |well| well['type'] == "wells" }
      expect(well['type']).to eq("wells")
      expect(well['id']).to eq(pacbio_plates.first.wells.first.id.to_s)
      expect(well['attributes']['position']).to eq(pacbio_plates.first.wells.first.position)

      material = json['included'].find { |well| well['type'] == "container_materials" }

      expect(material['type']).to eq("container_materials")

      request = pacbio_plates.first.wells.first.materials.first
      expect(material['id']).to eq(request.id.to_s)
      expect(material['attributes']['library_type']).to eq(request.library_type)
      expect(material['attributes']['estimate_of_gb_required']).to eq(request.estimate_of_gb_required)
      expect(material['attributes']['number_of_smrt_cells']).to eq(request.number_of_smrt_cells)
      expect(material['attributes']['cost_code']).to eq(request.cost_code)
      expect(material['attributes']['external_study_id']).to eq(request.external_study_id)
      expect(material['attributes']['sample_name']).to eq(request.sample_name)
      expect(material['attributes']['sample_species']).to eq(request.sample_species)
      expect(material['attributes']['material_type']).to eq('request')
    end

    it 'filtering by barcodes' do
      barcodes = pacbio_plates.pluck(:barcode)[0..1]
      get "#{v1_pacbio_plates_path}?filter[barcode]=#{barcodes.join(',')}", headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(barcodes.length)
      expect(json['data'][0]["attributes"]["barcode"]).to eq barcodes[0]
      expect(json['data'][1]["attributes"]["barcode"]).to eq barcodes[1]
    end

  end

  context '#create' do
    let(:external_plate) { build(:external_plate) }
    let(:body) do
      {
        data: {
          attributes: {
            plates: [
              external_plate
            ]
          }
        }
      }.to_json
    end

    context 'on success' do
      it 'has a created status' do
        post v1_pacbio_plates_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a plate' do
        expect { post v1_pacbio_plates_path, params: body, headers: json_api_headers }.to change { Plate.count }.by(1)
      end

      # the plate creator and resources are already tested but we can make sure
      # that the barcode is correct at least
      it 'has the correct attributes (sanity check)' do
        post v1_pacbio_plates_path, params: body, headers: json_api_headers
        expect(Plate.find_by(barcode: external_plate[:barcode])).to be_present
      end
    end

    context 'on failure' do
      let(:body) do
        {
          data: {
            attributes: {
              plates: []
            }
          }
        }.to_json
      end

      it 'has a ok unprocessable_entity' do
        post v1_pacbio_plates_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a plate' do
        expect { post v1_pacbio_plates_path, params: body, headers: json_api_headers }.to_not change(Plate, :count)
      end

      it 'has an error message' do
        post v1_pacbio_plates_path, params: body, headers: json_api_headers
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['errors']).to be_present
      end

    end
  end

end
