require "rails_helper"

RSpec.describe 'FlowcellsController', type: :request do

  context '#update' do
    let(:flowcell) { create(:flowcell) }
    let(:library) { create(:library) }

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

      it 'does not update a run' do
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

end
