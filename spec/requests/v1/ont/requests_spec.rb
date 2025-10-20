# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Ont::RequestsController', :ont do
  let(:request_resource_attributes) do
    {
      ** request.attributes.slice(Ont.direct_request_attributes),
      'library_type' => request.library_type.name,
      'data_type' => request.data_type.name
    }
  end

  describe '#get' do
    let!(:requests) { create_list(:ont_request, 5) }
    let(:request) { requests.last }

    it 'returns a list of requests' do
      get v1_ont_requests_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      expect(json['data'].length).to eq(5)
    end

    it 'returns the correct attributes' do
      get v1_ont_requests_path, headers: json_api_headers

      expect(json['data'][0]['attributes']).to include(request_resource_attributes)
    end

    context 'pagination' do
      context 'default' do
        let!(:expected_requests) { create_list(:ont_request, 5, created_at: Time.zone.now + 10) }

        before do
          # There should be 10 requests total
          # Since requests sorts by newest first by default they should be on the first page
          get "#{v1_ont_requests_path}?page[number]=1&page[size]=5",
              headers: json_api_headers
        end

        it 'has a success status' do
          expect(response).to have_http_status(:success), response.body
        end

        it 'returns a list of requests' do
          expect(json['data'].length).to eq(5)
        end

        it 'returns the correct attributes', :aggregate_failures do
          expected_requests.each do |request|
            request_attributes = find_resource(type: 'requests', id: request.id)['attributes']
            expect(request_attributes).to include(
              'cost_code' => request.cost_code,
              'number_of_flowcells' => request.number_of_flowcells,
              'external_study_id' => request.external_study_id,
              'library_type' => request.library_type.name,
              'data_type' => request.data_type.name,
              'created_at' => request.created_at.to_fs(:us)
            )
          end
        end
      end

      context 'non default' do
        let!(:expected_requests) { create_list(:ont_request, 5, created_at: Time.zone.now + 10) }

        before do
          # There should be 10 requests total
          # Sort by id instead of default created_at
          # The requests should now be sorted by id so the new ones should be last
          get "#{v1_ont_requests_path}?page[number]=2&page[size]=5&sort=id",
              headers: json_api_headers
        end

        it 'has a success status' do
          expect(response).to have_http_status(:success), response.body
        end

        it 'returns a list of requests' do
          expect(json['data'].length).to eq(5)
        end

        it 'returns the correct attributes', :aggregate_failures do
          expected_requests.each do |request|
            request_attributes = find_resource(type: 'requests', id: request.id)['attributes']
            expect(request_attributes).to include(
              'cost_code' => request.cost_code,
              'number_of_flowcells' => request.number_of_flowcells,
              'external_study_id' => request.external_study_id,
              'library_type' => request.library_type.name,
              'data_type' => request.data_type.name,
              'created_at' => request.created_at.to_fs(:us),
              'sample_name' => request.sample_name,
              'source_identifier' => request.source_identifier,
              'sample_retention_instruction' => request.sample_retention_instruction
            )
          end
        end
      end

      context 'filters - source_identifier' do
        it 'when the source_identifier belongs to a plate' do
          ont_plate = create(:plate_with_wells_and_requests)
          ont_plate_requests = ont_plate.wells.flat_map(&:ont_requests)
          get "#{v1_ont_requests_path}?filter[source_identifier]=#{ont_plate.barcode}",
              headers: json_api_headers

          expect(response).to have_http_status(:success)
          expect(json['data'].length).to eq(ont_plate_requests.length)
          ont_plate_requests.each do |request|
            request_attributes = find_resource(type: 'requests', id: request.id)['attributes']
            expect(request_attributes).to include(
              'cost_code' => request.cost_code,
              'number_of_flowcells' => request.number_of_flowcells,
              'external_study_id' => request.external_study_id,
              'library_type' => request.library_type.name,
              'data_type' => request.data_type.name,
              'created_at' => request.created_at.to_fs(:us),
              'sample_name' => request.sample_name,
              'source_identifier' => request.source_identifier,
              'sample_retention_instruction' => request.sample_retention_instruction
            )
          end
        end

        it 'when the source_identifier belongs to a tube' do
          ont_tube = create(:tube_with_ont_request)
          get "#{v1_ont_requests_path}?filter[source_identifier]=#{ont_tube.barcode}",
              headers: json_api_headers

          expect(response).to have_http_status(:success)
          expect(json['data'].length).to eq(ont_tube.ont_requests.length)
          ont_tube.ont_requests.each do |request|
            request_attributes = find_resource(type: 'requests', id: request.id)['attributes']
            expect(request_attributes).to include(
              'cost_code' => request.cost_code,
              'number_of_flowcells' => request.number_of_flowcells,
              'external_study_id' => request.external_study_id,
              'library_type' => request.library_type.name,
              'data_type' => request.data_type.name,
              'created_at' => request.created_at.to_fs(:us),
              'sample_name' => request.sample_name,
              'source_identifier' => request.source_identifier,
              'sample_retention_instruction' => request.sample.retention_instruction
            )
          end
        end

        it 'when the source_identifier contains multiple values' do
          ont_tube = create(:tube_with_ont_request)
          ont_plate = create(:plate_with_wells_and_requests)
          ont_plate_requests = ont_plate.wells.first.ont_requests
          source_identifiers = [
            ont_tube.barcode,
            "#{ont_plate.barcode}:#{ont_plate.wells.first.position}"
          ]
          get "#{v1_ont_requests_path}?filter[source_identifier]=#{source_identifiers.join(',')}",
              headers: json_api_headers

          expect(response).to have_http_status(:success)
          expect(json['data'].length).to eq(2)
          (ont_tube.ont_requests + ont_plate_requests).each do |request|
            request_attributes = find_resource(type: 'requests', id: request.id)['attributes']
            expect(request_attributes).to include(
              'cost_code' => request.cost_code,
              'number_of_flowcells' => request.number_of_flowcells,
              'external_study_id' => request.external_study_id,
              'library_type' => request.library_type.name,
              'data_type' => request.data_type.name,
              'created_at' => request.created_at.to_fs(:us),
              'sample_name' => request.sample_name,
              'source_identifier' => request.source_identifier,
              'sample_retention_instruction' => request.sample_retention_instruction
            )
          end
        end
      end
    end
  end

  describe '#update' do
    let!(:request) { create(:ont_request) }

    let(:body) do
      {
        data: {
          id: request.id.to_s,
          type: 'requests',
          attributes: request_resource_attributes.merge(cost_code: 'fraud')
        }
      }.to_json
    end

    it 'returns success status' do
      patch v1_ont_request_path(request), params: body, headers: json_api_headers
      expect(response).to have_http_status(:success), response.body
    end

    it 'updates the request' do
      patch v1_ont_request_path(request), params: body, headers: json_api_headers
      request.reload
      expect(request.cost_code).to eq('fraud')
    end
  end

  describe '#update - failure' do
    let!(:request) { create(:ont_request) }

    let(:body) do
      {
        data: {
          id: request.id.to_s,
          type: 'requests',
          attributes: request_resource_attributes.merge(external_study_id: nil)
        }
      }.to_json
    end

    it 'returns unprocessable entity status' do
      patch v1_ont_request_path(request), params: body, headers: json_api_headers
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'does not publish the message' do
      expect(Messages).not_to receive(:publish)
      patch v1_ont_request_path(request), params: body, headers: json_api_headers
    end
  end
end
