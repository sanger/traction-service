# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RequestsController', pacbio: true do
  describe '#get' do
    let!(:requests) { create_list(:pacbio_request, 2) }

    it 'returns a list of requests' do
      get v1_pacbio_requests_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get v1_pacbio_requests_path, headers: json_api_headers

      requests.each do |request|
        request_attributes = find_resource(type: 'requests', id: request.id)['attributes']
        expect(request_attributes).to include(
          'cost_code' => request.cost_code,
          'number_of_smrt_cells' => request.number_of_smrt_cells,
          'external_study_id' => request.external_study_id,
          'library_type' => request.library_type,
          'estimate_of_gb_required' => request.estimate_of_gb_required,
          'sample_name' => request.sample.name,
          'sample_species' => request.sample.species,
          'source_identifier' => request.source_identifier,
          'created_at' => request.created_at.to_fs(:us)
        )
      end
    end

    context 'pagination' do
      context 'default' do
        let!(:expected_requests) { create_list(:pacbio_request, 2, created_at: Time.zone.now + 10) }

        before do
          # There should be 4 requests total
          # Since requests sorts by newest first by default they should be on the first page
          get "#{v1_pacbio_requests_path}?page[number]=1&page[size]=2",
              headers: json_api_headers
        end

        it 'has a success status' do
          expect(response).to have_http_status(:success), response.body
        end

        it 'returns a list of requests' do
          expect(json['data'].length).to eq(2)
        end

        it 'returns the correct attributes', aggregate_failures: true do
          expected_requests.each do |request|
            request_attributes = find_resource(type: 'requests', id: request.id)['attributes']
            expect(request_attributes).to include(
              'cost_code' => request.cost_code,
              'number_of_smrt_cells' => request.number_of_smrt_cells,
              'external_study_id' => request.external_study_id,
              'library_type' => request.library_type,
              'estimate_of_gb_required' => request.estimate_of_gb_required,
              'sample_name' => request.sample.name,
              'sample_species' => request.sample.species,
              'source_identifier' => request.source_identifier,
              'created_at' => request.created_at.to_fs(:us)
            )
          end
        end
      end

      context 'filters' do
        context 'source_identifier' do
          it 'when the source_identifier belongs to a plate' do
            pacbio_plate = create(:plate_with_wells_and_requests, pipeline: 'pacbio')
            pacbio_plate_requests = pacbio_plate.wells.flat_map(&:pacbio_requests)
            get "#{v1_pacbio_requests_path}?filter[source_identifier]=#{pacbio_plate.barcode}",
                headers: json_api_headers

            expect(response).to have_http_status(:success)
            expect(json['data'].length).to eq(pacbio_plate_requests.length)
            pacbio_plate_requests.each do |request|
              request_attributes = find_resource(type: 'requests', id: request.id)['attributes']
              expect(request_attributes).to include(
                'cost_code' => request.cost_code,
                'number_of_smrt_cells' => request.number_of_smrt_cells,
                'external_study_id' => request.external_study_id,
                'library_type' => request.library_type,
                'estimate_of_gb_required' => request.estimate_of_gb_required,
                'sample_name' => request.sample.name,
                'sample_species' => request.sample.species,
                'source_identifier' => request.source_identifier,
                'created_at' => request.created_at.to_fs(:us)
              )
            end
          end

          it 'when the source_identifier belongs to a tube' do
            pacbio_tube = create(:tube_with_pacbio_request)
            get "#{v1_pacbio_requests_path}?filter[source_identifier]=#{pacbio_tube.barcode}",
                headers: json_api_headers

            expect(response).to have_http_status(:success)
            expect(json['data'].length).to eq(pacbio_tube.pacbio_requests.length)
            pacbio_tube.pacbio_requests.each do |request|
              request_attributes = find_resource(type: 'requests', id: request.id)['attributes']
              expect(request_attributes).to include(
                'cost_code' => request.cost_code,
                'number_of_smrt_cells' => request.number_of_smrt_cells,
                'external_study_id' => request.external_study_id,
                'library_type' => request.library_type,
                'estimate_of_gb_required' => request.estimate_of_gb_required,
                'sample_name' => request.sample.name,
                'sample_species' => request.sample.species,
                'source_identifier' => request.source_identifier,
                'created_at' => request.created_at.to_fs(:us)
              )
            end
          end
        end
      end
    end
  end

  describe '#destroy' do
    let!(:request) { create(:pacbio_request) }

    context 'on success' do
      it 'returns the correct status' do
        delete "#{v1_pacbio_requests_path}/#{request.id}", headers: json_api_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'destroys the request' do
        expect do
          delete "#{v1_pacbio_requests_path}/#{request.id}", headers: json_api_headers
        end.to change(Pacbio::Request, :count).by(-1)
      end
    end

    context 'on failure' do
      it 'does not delete the request' do
        delete "#{v1_pacbio_requests_path}/fakerequest", headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'has an error message' do
        delete "#{v1_pacbio_requests_path}/fakerequest", headers: json_api_headers
        data = response.parsed_body['data']
        expect(data['errors']).to be_present
      end
    end
  end

  describe '#update' do
    let!(:request) { create(:pacbio_request) }

    let(:body) do
      {
        data: {
          id: request.id.to_s,
          type: 'requests',
          attributes: request.attributes.slice(:library_type, :estimate_of_gb_required,
                                               :number_of_smrt_cells, :cost_code, :external_study_id).merge(cost_code: 'fraud')
        }
      }.to_json
    end

    it 'returns success status' do
      patch v1_pacbio_request_path(request), params: body, headers: json_api_headers
      expect(response).to have_http_status(:success), response.body
    end

    it 'updates the request' do
      patch v1_pacbio_request_path(request), params: body, headers: json_api_headers
      request.reload
      expect(request.cost_code).to eq('fraud')
    end

    it 'publishes a message' do
      # This might be overkill but wanted to ensure the right thing is happening
      expect(Messages).to receive(:publish).with(request.sequencing_plates,
                                                 having_attributes(pipeline: 'pacbio'))
      patch v1_pacbio_request_path(request), params: body, headers: json_api_headers
    end
  end

  describe '#update - failure' do
    let!(:request) { create(:pacbio_request) }

    let(:body) do
      {
        data: {
          id: request.id.to_s,
          type: 'requests',
          attributes: request.attributes.slice(:library_type, :estimate_of_gb_required,
                                               :number_of_smrt_cells, :cost_code, :external_study_id).merge(external_study_id: nil)
        }
      }.to_json
    end

    it 'returns unprocessable entity status' do
      patch v1_pacbio_request_path(request), params: body, headers: json_api_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'does not publish the message' do
      expect(Messages).not_to receive(:publish)
      patch v1_pacbio_request_path(request), params: body, headers: json_api_headers
    end
  end
end
