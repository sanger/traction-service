# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'LibraryBatchesController', :pacbio do
  describe '#create' do
    context 'when creating a library batch' do
      let!(:pacbio_requests) { create_list(:pacbio_request, 2) }
      let!(:tag) { create(:tag) }

      context 'on success' do
        let(:body) do
          {
            data: {
              type: 'library_batches',
              attributes: {
                libraries_attributes: [
                  {
                    volume: 1.11,
                    template_prep_kit_box_barcode: 'LK1234567',
                    concentration: 2.22,
                    insert_size: 100,
                    pacbio_request_id: pacbio_requests.first.id,
                    tag_id: tag.id,
                    primary_aliquot_attributes: {
                      volume: 1.11,
                      template_prep_kit_box_barcode: 'LK1234567',
                      concentration: 2.22,
                      insert_size: 100,
                      state: 'created',
                      tag_id: tag.id
                    }
                  },
                  volume: 1.11,
                  template_prep_kit_box_barcode: 'LK1234567',
                  concentration: 2.22,
                  insert_size: 100,
                  pacbio_request_id: pacbio_requests.second.id,
                  tag_id: tag.id,
                  primary_aliquot_attributes: {
                    volume: 1.11,
                    template_prep_kit_box_barcode: 'LK1234567',
                    concentration: 2.22,
                    insert_size: 100,
                    state: 'created',
                    tag_id: tag.id
                  }
                ]
              }
            }
          }.to_json
        end

        it 'has a created status' do
          post v1_pacbio_library_batches_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created), response.body
        end

        it 'creates a library and aliquots' do
          expect { post v1_pacbio_library_batches_path, params: body, headers: json_api_headers }
            .to change(Pacbio::Library, :count).by(2)
            .and change(Aliquot, :count).by(4) # We create a primary aliquot and a used_by aliquot for each library
        end

        it 'publish volume tracking messages for all libraries' do
          expect(Emq::Publisher).to receive(:publish).twice
          post v1_pacbio_library_batches_path, params: body, headers: json_api_headers
        end

        it 'returns the id' do
          post v1_pacbio_library_batches_path, params: body, headers: json_api_headers
          expect(json.dig('data', 'id').to_i).to eq(Pacbio::LibraryBatch.first.id)
        end

        it 'includes the libraries and their tubes' do
          post "#{v1_pacbio_library_batches_path}?include=libraries.tube", params: body, headers: json_api_headers
          expect(json['included'].length).to eq(4)
          expect(json['included'].filter { |record| record['type'] == 'tubes' }.length).to eq(2)
          expect(json['included'].filter { |record| record['type'] == 'libraries' }.length).to eq(2)
        end
      end

      context 'on failure - when a library is invalid' do
        let(:body) do
          {
            data: {
              type: 'library_batches',
              attributes: {
                libraries_attributes: [
                  {
                    volume: 1.11,
                    template_prep_kit_box_barcode: 'LK1234567',
                    concentration: 2.22,
                    insert_size: 'invalid insert size',
                    pacbio_request_id: pacbio_requests.first.id,
                    tag_id: tag.id,
                    primary_aliquot_attributes: {
                      volume: 1.11,
                      template_prep_kit_box_barcode: 'LK1234567',
                      concentration: 2.22,
                      insert_size: 100,
                      state: 'created',
                      tag_id: tag.id
                    }
                  },
                  volume: 1.11,
                  template_prep_kit_box_barcode: 'LK1234567',
                  concentration: 2.22,
                  insert_size: 100,
                  pacbio_request_id: pacbio_requests.second.id,
                  tag_id: tag.id,
                  primary_aliquot_attributes: {
                    volume: 1.11,
                    template_prep_kit_box_barcode: 'LK1234567',
                    concentration: 2.22,
                    insert_size: 100,
                    state: 'created',
                    tag_id: tag.id
                  }
                ]
              }
            }
          }.to_json
        end

        it 'returns unprocessable entity status' do
          post v1_pacbio_library_batches_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include('libraries.insert_size - is not a number')
        end

        it 'cannot create a library' do
          expect { post v1_pacbio_library_batches_path, params: body, headers: json_api_headers }.not_to(
            change(Pacbio::Library, :count) &&
            change(Aliquot, :count)
          )
        end
      end
    end
  end
end
