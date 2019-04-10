require "rails_helper"

RSpec.describe 'ChipsController', type: :request do

  context '#update' do
    let(:chip) { create(:chip) }
    let(:barcode) { 'FLEVEAOLPTOWPNWU20319131581014320190911XXXXXXXXXXXXX-2' }


    context 'on success' do
      let(:body) do
        {
          data: {
            type: "chips",
            id: chip.id,
            attributes: {
              barcode: barcode
            }
          }
        }.to_json
      end

      it 'has a ok status' do
        patch v1_chip_path(chip), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates a chip' do
        patch v1_chip_path(chip), params: body, headers: json_api_headers
        chip.reload
        expect(chip.barcode).to eq barcode
      end
    end

    context 'on failure' do
      let(:body) do
        {
          data: {
            type: "chips",
            id: chip.id,
            attributes: {
              barcode: barcode
            }
          }
        }.to_json
      end

      it 'has a ok unprocessable_entity' do
        patch v1_chip_path(123), params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not update a run' do
        patch v1_chip_path(123), params: body, headers: json_api_headers
        chip.reload
        expect(chip.barcode).to eq chip.barcode
      end

      it 'has an error message' do
        patch v1_chip_path(123), params: body, headers: json_api_headers
        expect(JSON.parse(response.body)).to include("errors" => "Couldn't find Chip with 'id'=123")
      end
    end
  end

end
