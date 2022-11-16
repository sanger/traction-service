# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/qc_results_uploads', type: :request do
  describe '#post' do
    context 'with valid parameters' do
      let(:csv) do
        " ,,SAMPLE INFORMATION,,,,,,,,,,,,,VOUCHERING,,,,EXTRACTION/QC,,,,,,,,,,,,,Shear & SPRI QC,,,,,,,,,,,,,,,,,,,,,,,,,,COLUMN JUST FOR TOL,SE LIMS,,
        Batch ,Tissue Tube ID,Sanger sample ID,Species,Genome Size,Tissue FluidX rack ID,Rack well location,Date,Crush Method,Tissue Mass (mg),Tissue type,Lysis ,DNA tube ID,DNAext FluidX Rack ID,Rack position,Voucher?,Voucher Tube ID,Voucher Rack ID,Sample Location,Qubit DNA Quant (ng/ul),DNA vol (ul),DNA total ng,Femto dilution,ND 260/280,ND 260/230,ND Quant (ng/ul),Femto Frag Size,GQN >30000,Femto pdf,LR DECISION,LMW Peak PE,TOL DECISION [Post-Extraction],Date started,Pre-shear SPRI Vol input (uL),SPRI Volume (x0.6),Final Elution (uL),DNA Fluid+ MR kit for viscous DNA?,MR Machine ID,MR speed,Vol Input DNA MR3 (uL),Save 1uL post shear,Vol Input SPRI (uL),SPRI volume (x0.6),Qubit Quant (ng/ul),Final Elution Volume (ul),Total DNA ng,Femto Dil (ul),ND 260/280,ND 260/230,ND Quant (ng/uL),% DNA Recovery,Femto Fragment size (mode),GQN 10kb threshold,Femto pdf,LMW Peak PS,LR DECISION,Date Complete,TOL DECISION [Post-Shearing],ToL ID ,SE Number,Date in PB Lab (Auto),PB CCS Yield (Gb)
        Production 1,FD20709764,DTOL12932860,,0.53,,,04/05/2022,Powermash,7.8,Non-plant,2h@25C,,,NA,Yes,FD38542652,SA00930879,A1,4.78,385,1840.3,18.12,2.38,0.57,14.9,22688,1.5,Extraction.Femto.9764-9765,Pass,,,05/05/2022,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,22.6,45.4,1026.04,89.4,1.92,1.79,33.7,55.8,9772,4.4,Sheared.Femto.9764-6843,,Pass,,,idCheUrba1,SE293337P,24/06/2022,20.18
        Production 1,FD20706871,DTOL12932868,,0.48,,,04/05/2022,Powermash,21,Non-plant,2h@25C,,,,Yes,FD38542653,SA00930879,B1 ,3.1,385,1193.5,11.4,1.79,0.33,7.4,44697,3.9,Extraction.Femto.9764-9765,Pass,,,05/05/2022,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,15.8,45.4,717.32,62.2,1.85,1.25,26,60.1,14833,8.9,Sheared.Femto.9764-6843,,Pass,,,ilNemSwae1,SE293338Q,24/06/2022,27.56"
      end

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
          expect(JSON.parse(response.parsed_body)["errors"][0]["detail"]).to eq "csv_data - can't be blank"
        end
      end
      context 'when csv_data is empty' do
        let(:invalid_body) do
          {
            data: {
              type: 'qc_results_uploads',
              attributes: {
                csv_data: "",
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
          expect(JSON.parse(response.parsed_body)["errors"][0]["detail"]).to eq "csv_data - can't be blank"
        end
      end
      context 'when used_by is missing' do
        let(:invalid_body) do
          {
            data: {
              type: 'qc_results_uploads',
              attributes: {
                csv_data: "xx",
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
          expect(JSON.parse(response.parsed_body)["errors"][0]["detail"]).to eq "used_by - can't be blank"
        end
      end
      context 'when used_by is empty' do
        let(:invalid_body) do
          {
            data: {
              type: 'qc_results_uploads',
              attributes: {
                csv_data: "xx",
                used_by: ""
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
          expect(JSON.parse(response.parsed_body)["errors"][0]["detail"]).to eq "used_by - can't be blank"
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
        expect(JSON.parse(response.parsed_body)["errors"][0]["detail"]).to eq "The required parameter, data, is missing."
      end
    end
  end
end
