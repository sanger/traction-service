# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/qc_receptions' do
  describe '#post' do
    before do
      # QcAssayType for Extraction - to be ignored
      create(:qc_assay_type, key: 'qubit_concentration_ngul', label: 'Qubit DNA Quant (ng/ul) [ESP1]', used_by: 0, units: 'ng/ul')
      # Relevant QcAssayType for ToL
      create(:qc_assay_type, key: 'sheared_femto_fragment_size', label: 'Sheared Femto Fragment Size (bp)', used_by: 2, units: 'bp')
    end

    let(:qc_results_list) do
      [
        {
          final_nano_drop: '200',
          final_nano_drop_230: '230',
          final_nano_drop_280: '280',
          post_spri_concentration: '10',
          post_spri_volume: '20',
          sheared_femto_fragment_size: '5',
          shearing_qc_comments: 'Comments',
          date_required_by: 'Long Read',
          labware_barcode: 'FD20706500',
          priority_level: 'Medium',
          reason_for_priority: 'Reason goes here',
          sample_external_id: 'supplier_sample_name_DDD'
        }
      ]
    end

    let(:source) { 'tol-lab-share.tol' }

    context 'with valid parameters' do
      let(:body) do
        {
          data: {
            type: 'qc_receptions',
            attributes: {
              source:,
              qc_results_list:
            }
          }
        }.to_json
      end

      it 'returns a created status' do
        post v1_qc_receptions_url, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a new QcReception' do
        expect do
          post v1_qc_receptions_url, params: body, headers: json_api_headers
        end.to change(QcReception, :count).by(1)
      end

      it 'creates a new QcReception with the given source' do
        post v1_qc_receptions_url, params: body, headers: json_api_headers
        expect(QcReception.last.source).to eq source
      end

      it 'creates the relevant QcResult' do
        expect do
          post v1_qc_receptions_url, params: body, headers: json_api_headers
        end.to change(QcResult, :count).by(1)
      end

      it 'creates the relevant QcResult data' do
        post v1_qc_receptions_url, params: body, headers: json_api_headers
        expect(QcResult.last.labware_barcode).to eq 'FD20706500'
        expect(QcResult.last.sample_external_id).to eq 'supplier_sample_name_DDD'
        expect(QcResult.last.qc_assay_type_id).to eq QcAssayType.find_by(key: 'sheared_femto_fragment_size').id
        expect(QcResult.last.value).to eq '5'
        expect(QcResult.last.date_required_by).to eq 'Long Read'
        expect(QcResult.last.priority_level).to eq 'Medium'
        expect(QcResult.last.reason_for_priority).to eq 'Reason goes here'
      end

      # TODO: DPL-754: test message data?
      it 'sends the messages' do
        # 1 as there is 1 QcResult created
        expect(Broker::Handle).to receive(:publish).once
        post v1_qc_receptions_url, params: body, headers: json_api_headers
      end

      it 'renders a JSON response with the new qc_receptions' do
        post v1_qc_receptions_url, params: body, headers: json_api_headers
        expect(response.content_type).to match(a_string_including('application/vnd.api+json'))
      end

      context 'when there are no matching QcAssayTypes' do
        before do
          QcAssayType.destroy_all
        end

        it 'does not create a new QcReception' do
          expect do
            post v1_qc_receptions_url, params: body, headers: json_api_headers
          end.not_to change(QcReception, :count)
        end

        it 'does not create any QcResults' do
          expect do
            post v1_qc_receptions_url, params: body, headers: json_api_headers
          end.not_to change(QcResult, :count)
        end
      end
    end

    context 'with invalid parameters' do
      context 'when qc_results_list is missing' do
        let(:invalid_body) do
          {
            data: {
              type: 'qc_receptions',
              attributes: {
                source:
                # qc_results_list: qc_results_list
              }
            }
          }.to_json
        end

        it 'does not create a new QcReception' do
          expect do
            post v1_qc_receptions_url, params: invalid_body, headers: json_api_headers
          end.not_to change(QcReception, :count)
        end

        it 'renders a JSON response with errors for the new qc_receptions' do
          post v1_qc_receptions_url, params: invalid_body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/vnd.api+json'))
          expect(JSON.parse(response.parsed_body)['errors'][0]['detail']).to eq "qc_results_list - can't be blank"
        end
      end

      context 'when qc_results_list is an empty list' do
        let(:invalid_body) do
          {
            data: {
              type: 'qc_receptions',
              attributes: {
                source:,
                qc_results_list: []
              }
            }
          }.to_json
        end

        it 'does not create a new QcReception' do
          expect do
            post v1_qc_receptions_url, params: invalid_body, headers: json_api_headers
          end.not_to change(QcReception, :count)
        end

        it 'renders a JSON response with errors for the new qc_receptions' do
          post v1_qc_receptions_url, params: invalid_body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/vnd.api+json'))
          expect(JSON.parse(response.parsed_body)['errors'][0]['detail']).to eq "qc_results_list - can't be blank"
        end
      end

      context 'when qc_results_list is an empty object' do
        let(:invalid_body) do
          {
            data: {
              type: 'qc_receptions',
              attributes: {
                source:,
                qc_results_list: [{}]
              }
            }
          }.to_json
        end

        it 'does not create a new QcReception' do
          expect do
            post v1_qc_receptions_url, params: invalid_body, headers: json_api_headers
          end.not_to change(QcReception, :count)
        end

        it 'renders a JSON response with errors for the qc_results_list' do
          post v1_qc_receptions_url, params: invalid_body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/vnd.api+json'))
          expect(JSON.parse(response.parsed_body)['errors'][0]['detail']).to eq 'qc_results_list - Is empty'
        end
      end

      context 'when source is missing' do
        let(:invalid_body) do
          {
            data: {
              type: 'qc_receptions',
              attributes: {
                qc_results_list:
              }
            }
          }.to_json
        end

        it 'does not create a new QcReception' do
          expect do
            post v1_qc_receptions_url, params: invalid_body, headers: json_api_headers
          end.not_to change(QcReception, :count)
        end

        it 'renders a JSON response with errors for the new qc_receptions' do
          post v1_qc_receptions_url, params: invalid_body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/vnd.api+json'))
          expect(JSON.parse(response.parsed_body)['errors'][0]['detail']).to eq "source - can't be blank"
        end
      end

      context 'when source is empty' do
        let(:invalid_body) do
          {
            data: {
              type: 'qc_receptions',
              attributes: {
                source: '',
                qc_results_list:
              }
            }
          }.to_json
        end

        it 'does not create a new QcReception' do
          expect do
            post v1_qc_receptions_url, params: invalid_body, headers: json_api_headers
          end.not_to change(QcReception, :count)
        end

        it 'renders a JSON response with errors for the new qc_results_list' do
          post v1_qc_receptions_url, params: invalid_body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including('application/vnd.api+json'))
          expect(JSON.parse(response.parsed_body)['errors'][0]['detail']).to eq "source - can't be blank"
        end
      end

      context 'when data is missing' do
        let(:invalid_body) do
          {}.to_json
        end

        it 'does not create a new QcReception' do
          expect do
            post v1_qc_receptions_url, params: invalid_body, headers: json_api_headers
          end.not_to change(QcReception, :count)
        end

        it 'renders a JSON response with errors for the new qc_receptions' do
          post v1_qc_receptions_url, params: invalid_body, headers: json_api_headers
          expect(response).to have_http_status(:bad_request)
          expect(response.content_type).to match(a_string_including('application/vnd.api+json'))
          expect(JSON.parse(response.parsed_body)['errors'][0]['detail']).to eq 'The required parameter, data, is missing.'
        end
      end
    end
  end
end
