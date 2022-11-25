# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/qc_results_uploads', type: :request do
  describe '#post' do
    before do
      create(:qc_assay_type, key: 'qubit_concentration_ngul', label: 'Qubit DNA Quant (ng/ul) [ESP1]', used_by: 0)
      create(:qc_assay_type, key: 'volume_si', label: 'DNA vol (ul)', used_by: 0)
      create(:qc_assay_type, key: '_260_230_ratio', label: 'ND 260/230 [ESP1]', used_by: 0)
      create(:qc_assay_type, key: '_260_280_ratio', label: 'ND 260/280 [ESP1]', used_by: 0)
      create(:qc_assay_type, key: '_tbc_', label: 'Femto Frag Size [ESP1]', used_by: 0)
      create(:qc_assay_type, key: 'results_pdf', label: 'Femto pdf [ESP1]', used_by: 0)
    end

    context 'with valid parameters' do
      let(:csv) { build(:qc_results_upload).csv_data }

      let(:body) do
        {
          data: {
            type: 'qc_results_uploads',
            attributes: {
              csv_data: csv,
              used_by: 'extraction'
            }
          }
        }.to_json
      end

      it 'returns a created status' do
        post v1_qc_results_uploads_url, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created), response.body
      end

      it 'creates a new QcResultsUpload' do
        expect do
          post v1_qc_results_uploads_url, params: body, headers: json_api_headers
        end.to change(QcResultsUpload, :count).by(1)
      end

      it 'creates a new QcResultsUpload with the given csv_data' do
        post v1_qc_results_uploads_url, params: body, headers: json_api_headers
        expect(QcResultsUpload.last.csv_data).to eq csv
      end

      it 'renders a JSON response with the new qc_results_upload' do
        post v1_qc_results_uploads_url, params: body, headers: json_api_headers
        expect(response.content_type).to match(a_string_including('application/vnd.api+json'))
      end

      it 'creates the relevant entities' do
        # 14 = 8 LR + 6 TOL
        expect do
          post v1_qc_results_uploads_url, params: body, headers: json_api_headers
        end.to change(QcDecision, :count).by(14)

        # 42 = 6 assay types x 8 rows
        expect do
          post v1_qc_results_uploads_url, params: body, headers: json_api_headers
        end.to change(QcResult, :count).by(48)

        # row	dec	results	dec_res
        # 1	  2   6	      12
        # 2	  2   6	      12
        # 3	  2   6	      12
        # 4	  2   6	      12
        # 5	  1   6	      6
        # 6	  2   6	      12
        # 7	  1   6	      6
        # 8	  2   6	      12
        #                 84
        expect do
          post v1_qc_results_uploads_url, params: body, headers: json_api_headers
        end.to change(QcDecisionResult, :count).by(84)
      end
    end

    context 'with invalid parameters' do
      context 'when csv_data is missing' do
        let(:invalid_body) do
          {
            data: {
              type: 'qc_results_uploads',
              attributes: {
                used_by: 'extraction'
              }
            }
          }.to_json
        end

        it 'does not create a new QcResultsUpload' do
          expect do
            post v1_qc_results_uploads_url, params: invalid_body, headers: json_api_headers
          end.not_to change(QcResultsUpload, :count)
        end

        it 'renders a JSON response with errors for the new qc_results_upload' do
          post v1_qc_results_uploads_url, params: invalid_body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/vnd.api+json'))
          expect(JSON.parse(response.parsed_body)['errors'][0]['detail']).to eq "csv_data - can't be blank"
        end
      end

      context 'when csv_data is empty' do
        let(:invalid_body) do
          {
            data: {
              type: 'qc_results_uploads',
              attributes: {
                csv_data: '',
                used_by: 'extraction'
              }
            }
          }.to_json
        end

        it 'does not create a new QcResultsUpload' do
          expect do
            post v1_qc_results_uploads_url, params: invalid_body, headers: json_api_headers
          end.not_to change(QcResultsUpload, :count)
        end

        it 'renders a JSON response with errors for the new qc_results_upload' do
          post v1_qc_results_uploads_url, params: invalid_body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/vnd.api+json'))
          expect(JSON.parse(response.parsed_body)['errors'][0]['detail']).to eq "csv_data - can't be blank"
        end
      end

      context 'when used_by is missing' do
        let(:invalid_body) do
          {
            data: {
              type: 'qc_results_uploads',
              attributes: {
                csv_data: 'xx'
              }
            }
          }.to_json
        end

        it 'does not create a new QcResultsUpload' do
          expect do
            post v1_qc_results_uploads_url, params: invalid_body, headers: json_api_headers
          end.not_to change(QcResultsUpload, :count)
        end

        it 'renders a JSON response with errors for the new qc_results_upload' do
          post v1_qc_results_uploads_url, params: invalid_body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/vnd.api+json'))
          expect(JSON.parse(response.parsed_body)['errors'][0]['detail']).to eq "used_by - can't be blank"
        end
      end

      context 'when used_by is empty' do
        let(:invalid_body) do
          {
            data: {
              type: 'qc_results_uploads',
              attributes: {
                csv_data: 'xx',
                used_by: ''
              }
            }
          }.to_json
        end

        it 'does not create a new QcResultsUpload' do
          expect do
            post v1_qc_results_uploads_url, params: invalid_body, headers: json_api_headers
          end.not_to change(QcResultsUpload, :count)
        end

        it 'renders a JSON response with errors for the new qc_results_upload' do
          post v1_qc_results_uploads_url, params: invalid_body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/vnd.api+json'))
          expect(JSON.parse(response.parsed_body)['errors'][0]['detail']).to eq "used_by - can't be blank"
        end
      end
    end

    context 'when data is missing' do
      let(:invalid_body) do
        {}.to_json
      end

      it 'does not create a new QcResultsUpload' do
        expect do
          post v1_qc_results_uploads_url, params: invalid_body, headers: json_api_headers
        end.not_to change(QcResultsUpload, :count)
      end

      it 'renders a JSON response with errors for the new qc_results_upload' do
        post v1_qc_results_uploads_url, params: invalid_body, headers: json_api_headers
        expect(response).to have_http_status(:bad_request)
        expect(response.content_type).to match(a_string_including('application/vnd.api+json'))
        # can this be refactored?
        expect(JSON.parse(response.parsed_body)['errors'][0]['detail']).to eq 'The required parameter, data, is missing.'
      end
    end
  end
end
