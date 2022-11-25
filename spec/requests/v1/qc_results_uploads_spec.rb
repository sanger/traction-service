# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/qc_results_uploads', type: :request do
  describe '#post' do
    before do
      create(:qc_assay_type, key: 'qubit_concentration_ngul', label: 'Qubit DNA Quant (ng/ul) [ESP1]', used_by: 0)
      create(:qc_assay_type, key: 'volume_si', label: 'DNA vol (ul)', used_by: 0)
      create(:qc_assay_type, key: '_260_230_ratio', label: 'ND 260/230 [ESP1]', used_by: 0)
      create(:qc_assay_type, key: '_260_280_ratio', label: 'ND 260/280 [ESP1]', used_by: 0)
      create(:qc_assay_type, key: 'average_fragment_size', label: 'Femto Frag Size [ESP1]', used_by: 0)
      create(:qc_assay_type, key: 'results_pdf', label: 'Femto pdf [ESP1]', used_by: 0)
      create(:qc_assay_type, key: 'a_future_key', label: 'A Future Label', used_by: 1)
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
        expect(response).to have_http_status(:created)
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

      it 'creates the relevant QC entities' do
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
          expect(JSON.parse(response.parsed_body)['errors'][0]['detail']).to eq 'The required parameter, data, is missing.'
        end
      end

      context 'when csv_data headers is missing' do
        let(:csv_missing_headers) do
          ',,SAMPLE INFORMATION,,,,,,,,,,,,,VOUCHERING,,,,EXTRACTION/QC,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,COLUMN JUST FOR TOL,COLUMN JUST FOR TOL,SE LIMS,'
        end

        let(:invalid_body) do
          {
            data: {
              type: 'qc_results_uploads',
              attributes: {
                csv_data: csv_missing_headers,
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
          expect(JSON.parse(response.parsed_body)['errors'][0]['detail']).to eq 'csv_data - Missing headers'
        end
      end

      context 'when csv_data body data is missing' do
        let(:csv_missing_body) do
          ",,SAMPLE INFORMATION,,,,,,,,,,,,,VOUCHERING,,,,EXTRACTION/QC,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,COLUMN JUST FOR TOL,COLUMN JUST FOR TOL,SE LIMS,
          Batch ,Tissue Tube ID,Sanger sample ID,Species,Genome Size,Tissue FluidX rack ID,Rack well location,Date,Crush Method,Tissue Mass (mg),Tissue type,Lysis ,DNA tube ID,DNAext FluidX Rack ID,Rack position,Voucher?,Voucher Tube ID,Voucher Rack ID,Sample Location,Qubit DNA Quant (ng/ul) [ESP1],DNA vol (ul),DNA total ng [ESP1],Femto dilution [ESP1],ND 260/280 [ESP1],ND 260/230 [ESP1],ND Quant (ng/ul) [ESP1],Femto Frag Size [ESP1],GQN >30000 [ESP1],Femto pdf [ESP1],LR EXTRACTION DECISION [ESP1],Sample Well Position in Plate,TOL DECISION [ESP1],DNA Fluid+ MR kit for viscous DNA?,MR Machine ID,MR speed,Vol Input DNA MR3 (uL),Save 1uL post shear,Vol Input SPRI (uL),SPRI volume (x0.6),Qubit Quant (ng/ul) [ESP2],Final Elution Volume (ul),Total DNA ng [ESP2],Femto Dil (ul) [ESP2],ND 260/280 [ESP2],ND 260/230 [ESP2],ND Quant (ng/uL) [ESP2],% DNA Recovery,Femto Fragment size [ESP2],GQN 10kb threshold [ESP2],Femto pdf [ESP2],LR SHEARING DECISION [ESP2],TOL DECISION [ESP2],ToL ID ,Genome size (TOL),SE Number,Date in PB Lab (Auto)"
        end

        let(:invalid_body) do
          {
            data: {
              type: 'qc_results_uploads',
              attributes: {
                csv_data: csv_missing_body,
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
          expect(JSON.parse(response.parsed_body)['errors'][0]['detail']).to eq 'csv_data - Missing data'
        end
      end

      context 'when required row data is missing' do
        let(:csv_missing_lr_decision) do
          ",,SAMPLE INFORMATION,,,,,,,,,,,,,VOUCHERING,,,,EXTRACTION/QC,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,COLUMN JUST FOR TOL,COLUMN JUST FOR TOL,SE LIMS,
          Batch ,Tissue Tube ID,Sanger sample ID,Species,Genome Size,Tissue FluidX rack ID,Rack well location,Date,Crush Method,Tissue Mass (mg),Tissue type,Lysis ,DNA tube ID,DNAext FluidX Rack ID,Rack position,Voucher?,Voucher Tube ID,Voucher Rack ID,Sample Location,Qubit DNA Quant (ng/ul) [ESP1],DNA vol (ul),DNA total ng [ESP1],Femto dilution [ESP1],ND 260/280 [ESP1],ND 260/230 [ESP1],ND Quant (ng/ul) [ESP1],Femto Frag Size [ESP1],GQN >30000 [ESP1],Femto pdf [ESP1],LR EXTRACTION DECISION [ESP1],Sample Well Position in Plate,TOL DECISION [ESP1],DNA Fluid+ MR kit for viscous DNA?,MR Machine ID,MR speed,Vol Input DNA MR3 (uL),Save 1uL post shear,Vol Input SPRI (uL),SPRI volume (x0.6),Qubit Quant (ng/ul) [ESP2],Final Elution Volume (ul),Total DNA ng [ESP2],Femto Dil (ul) [ESP2],ND 260/280 [ESP2],ND 260/230 [ESP2],ND Quant (ng/uL) [ESP2],% DNA Recovery,Femto Fragment size [ESP2],GQN 10kb threshold [ESP2],Femto pdf [ESP2],LR SHEARING DECISION [ESP2],TOL DECISION [ESP2],ToL ID ,Genome size (TOL),SE Number,Date in PB Lab (Auto)
          Production 1,FD20709764,DTOL12932860,,0.53,,,04/05/2022,Powermash,7.8,Non-plant,2h@25C,,,NA,Yes,FD38542652,SA00930879,A1,4.78,385,1840.3,18.12,2.38,0.57,14.9,22688,1.5,Extraction.Femto.9764-9765,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,22.6,45.4,1026.04,89.4,1.92,1.79,33.7,55.8,9772,4.4,Sheared.Femto.9764-6843,Pass,,idCheUrba1,0.52725,SE293337P,24/06/2022"
        end

        let(:invalid_body) do
          {
            data: {
              type: 'qc_results_uploads',
              attributes: {
                csv_data: csv_missing_lr_decision,
                used_by: 'extraction'
              }
            }
          }.to_json
        end

        it 'does create a new QcResultsUpload' do
          expect do
            post v1_qc_results_uploads_url, params: invalid_body, headers: json_api_headers
          end.not_to change(QcResultsUpload, :count)
        end

        # There should always be a LR Decision, throw a 500 if not
        it 'renders a JSON response with errors for the new qc_results_upload' do
          post v1_qc_results_uploads_url, params: invalid_body, headers: json_api_headers
          expect(response).to have_http_status(:internal_server_error)
          expect(response.content_type).to match(a_string_including('application/vnd.api+json'))
          expect(JSON.parse(response.parsed_body)['errors'][0]['meta']['exception']).to eq "Validation failed: Status can't be blank"
        end
      end
    end
  end
end
