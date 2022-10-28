# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "/qc_results_uploads", type: :request do

  describe '#post' do
    context "with valid parameters" do
      xit "creates a new QcResultsUpload" do
        expect {
          post qc_results_uploads_url,
               params: { qc_results_upload: valid_attributes }, headers: valid_headers, as: :json
        }.to change(QcResultsUpload, :count).by(1)
      end

      xit "renders a JSON response with the new qc_results_upload" do
        post qc_results_uploads_url,
             params: { qc_results_upload: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      xit "does not create a new QcResultsUpload" do
        expect {
          post qc_results_uploads_url,
               params: { qc_results_upload: invalid_attributes }, as: :json
        }.to change(QcResultsUpload, :count).by(0)
      end

      xit "renders a JSON response with errors for the new qc_results_upload" do
        post qc_results_uploads_url,
             params: { qc_results_upload: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end
end
