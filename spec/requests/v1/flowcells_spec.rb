require "rails_helper"

RSpec.describe 'FlowcellsController', type: :request do

  let(:library) { create(:library) }

  context '#create' do

    let(:chip) { create(:chip) }

    context 'on success' do
      let(:body) do
        {
          data: {
            type: "flowcells",
            attributes: {
              "position": 1,
              "library_id": library.id,
              "chip_id": chip.id
            }
          }
        }.to_json
      end

      it 'has a created status' do
        post v1_flowcells_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a flowcell' do
        expect { post v1_flowcells_path, params: body, headers: json_api_headers }.to change(Flowcell, :count).by(1)
      end
    end

    context 'on failure' do
      let(:body) do
        {
          data: {
            type: "flowcells",
            attributes: {
              "library_id": library.id,
              "chip_id": chip.id
            }
          }
        }.to_json
      end

      it 'has a ok unprocessable_entity' do
        post v1_flowcells_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a flowcell' do
        expect { post v1_flowcells_path, params: body, headers: json_api_headers }.to_not change(Flowcell, :count)
      end

      it 'has an error message' do
        post v1_flowcells_path, params: body, headers: json_api_headers
        expect(JSON.parse(response.body)["data"]["errors"].length).to eq(1)
      end
    end
  end

  context '#update' do
    let(:flowcell) { create(:flowcell) }

    context 'on success' do
      let(:body) do
        {
          data: {
            type: "flowcells",
            id: flowcell.id,
            attributes: {
              "library_id":library.id
            }
          }
        }.to_json
      end

      it 'has a ok status' do
        patch v1_flowcell_path(flowcell), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates a flowcell' do
        patch v1_flowcell_path(flowcell), params: body, headers: json_api_headers
        flowcell.reload
        expect(flowcell.library).to eq library
      end
    end

    context 'on failure' do
      let(:body) do
        {
          data: {
            type: "flowcells",
            id: flowcell.id,
            attributes: {
              "library_id":library.id
            }
          }
        }.to_json
      end

      it 'has a ok unprocessable_entity' do
        patch v1_flowcell_path(123), params: body, headers: json_api_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not update a flowcell' do
        patch v1_flowcell_path(123), params: body, headers: json_api_headers
        flowcell.reload
        expect(flowcell.library).to eq nil
      end

      it 'has an error message' do
        patch v1_flowcell_path(123), params: body, headers: json_api_headers
        expect(JSON.parse(response.body)["data"]).to include("errors" => "Couldn't find Flowcell with 'id'=123")
      end
    end
  end

  context '#destroy' do

    let(:flowcell) { create(:flowcell) }

    it 'has a status of no content' do
      delete v1_flowcell_path(flowcell), headers: json_api_headers
      expect(response).to have_http_status(:no_content)
    end

  end

end
