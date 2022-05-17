require "rails_helper"

RSpec.describe 'ChipsController', type: :request do

  let(:barcode) { 'FLEVEAOLPTOWPNWU20319131581014320190911XXXXXXXXXXXXX-2' }

  context '#create' do
    let(:run) { create(:saphyr_run) }

    context 'on success' do
      let(:body) do
        {
          data: {
            type: "chips",
            attributes: {
              barcode: barcode,
              saphyr_run_id: run.id
            }
          }
        }.to_json
      end

      it 'has a ok status' do
        post v1_saphyr_chips_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created)
      end

      it 'has the correct attributes' do
        post v1_saphyr_chips_path, params: body, headers: json_api_headers
        chip = Saphyr::Chip.first
        expect(chip.barcode).to eq barcode
        expect(chip.run).to eq run
      end


    end

    context 'on failure' do
      let(:body) do
        {
          data: {
            type: "chips",
            attributes: {
              run_id: run.id
            }
          }
        }.to_json
      end

      it 'has a ok unprocessable_entity' do
        post v1_saphyr_chips_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a chip' do
        expect { post v1_saphyr_chips_path, params: body, headers: json_api_headers }.to_not change(Saphyr::Chip, :count)
      end

      it 'has an error message' do
        post v1_saphyr_chips_path, params: body, headers: json_api_headers
        expect(JSON.parse(response.body)["data"]["errors"].length).to eq(1)
      end

    end
  end

  context '#update' do
    let(:chip) { create(:saphyr_chip) }

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
        patch v1_saphyr_chip_path(chip), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates a chip' do
        patch v1_saphyr_chip_path(chip), params: body, headers: json_api_headers
        chip.reload
        expect(chip.barcode).to eq barcode
      end

      it 'sends a message to the warehouse' do
        expect(Messages).to receive(:publish)
        patch v1_saphyr_chip_path(chip), params: body, headers: json_api_headers
      end

      it 'returns the correct attributes' do
        patch v1_saphyr_chip_path(chip), params: body, headers: json_api_headers
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['id']).to eq chip.id.to_s
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
        patch v1_saphyr_chip_path(123), params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not update a chip' do
        patch v1_saphyr_chip_path(123), params: body, headers: json_api_headers
        chip.reload
        expect(chip.barcode).to eq chip.barcode
      end

      it 'has an error message' do
        patch v1_saphyr_chip_path(123), params: body, headers: json_api_headers
        expect(JSON.parse(response.body)["data"]).to include("errors" => "Couldn't find Saphyr::Chip with 'id'=123")
      end
    end
  end

  context '#destroy' do

    let(:chip) { create(:saphyr_chip) }

    it 'has a status of ok' do
      delete v1_saphyr_chip_path(chip), headers: json_api_headers
      expect(response).to have_http_status(:no_content)
    end

  end

end
