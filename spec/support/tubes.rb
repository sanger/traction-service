require "rails_helper"

shared_examples_for 'tubes' do

  let(:pipeline_tube_request_factory)       { "tube_with_#{pipeline_name}_request".to_sym }
  let(:other_pipeline_tube_request_factory) { "tube_with_#{other_pipeline_name}_request".to_sym }
  let(:pipeline_tube_library_factory)       { "tube_with_#{pipeline_name}_library".to_sym }
  let(:other_pipeline_tube_library_factory) { "tube_with_#{other_pipeline_name}_library".to_sym }
  let(:tubes_path)                          { "v1_#{pipeline_name}_tubes_path" }

  context '#get' do
    context 'tubes' do
      let!(:other_pipeline_tubes) { create_list(other_pipeline_tube_library_factory, 2)}
      let!(:pipeline_tubes)       { create_list(pipeline_tube_library_factory, 3)}

      it 'returns a list' do
        get send(tubes_path), headers: json_api_headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'].length).to eq(3)
      end
    end

    context 'when material is a request' do
      let!(:other_pipeline_tube_request)   { create(other_pipeline_tube_request_factory)}
      let!(:pipeline_tube_requests)        { create_list(pipeline_tube_request_factory, 2)}
     
      it 'returns the correct attributes' do
        get send(tubes_path), headers: json_api_headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)

        tube = pipeline_tube_requests.first
        expect(json['data'][0]['attributes']['barcode']).to eq(tube.barcode)
        expect(json['data'][0]['relationships']['material']).to be_present
        expect(json['data'][0]['relationships']['material']['data']['type']).to eq("requests")
        expect(json['data'][0]['relationships']['material']['data']['id'].to_s).to eq(tube.material.id.to_s)

        tube = pipeline_tube_requests.last
        expect(json['data'][1]['attributes']['barcode']).to eq(tube.barcode)
        expect(json['data'][1]['relationships']['material']).to be_present
        expect(json['data'][1]['relationships']['material']['data']['type']).to eq("requests")
        expect(json['data'][1]['relationships']['material']['data']['id']).to eq(tube.material.id.to_s)

      end
    end

    context 'when material is a library' do
      let!(:other_pipeline_tube_library)  { create(other_pipeline_tube_library_factory)}
      let!(:pipeline_tube_libraries)      { create_list(pipeline_tube_library_factory, 2)}

      it 'returns the correct attributes' do
        get send(tubes_path), headers: json_api_headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)

        tube = pipeline_tube_libraries.first
        expect(json['data'][0]['attributes']['barcode']).to eq(tube.barcode)
        expect(json['data'][0]['relationships']['material']).to be_present
        expect(json['data'][0]['relationships']['material']['data']['type']).to eq("libraries")
        expect(json['data'][0]['relationships']['material']['data']['id']).to eq(tube.material.id.to_s)

        tube = pipeline_tube_libraries.last
        expect(json['data'][1]['attributes']['barcode']).to eq(tube.barcode)
        expect(json['data'][1]['relationships']['material']).to be_present
        expect(json['data'][1]['relationships']['material']['data']['type']).to eq("libraries")
        expect(json['data'][1]['relationships']['material']['data']['id']).to eq(tube.material.id.to_s)
      end
    end

    describe 'filter' do
      context 'when filtering by barcode' do
        let(:tubes_with_request) { create_list(pipeline_tube_request_factory, 2)}

        it 'returns the correct tube' do
          barcode = tubes_with_request[0].barcode
          get "#{send(tubes_path)}?filter[barcode]=#{barcode}", headers: json_api_headers
          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)
          expect(json['data'].length).to eq(1)
          expect(json['data'][0]["attributes"]["barcode"]).to eq barcode
        end
      end

      context 'filtering by barcodes' do
        let(:tubes_with_library) { create_list(pipeline_tube_library_factory, 4)}

        it 'returns the correct tubes' do
          barcodes = tubes_with_library.map(&:barcode)[0..1]
          get "#{send(tubes_path)}?filter[barcode]=#{barcodes.join(',')}", headers: json_api_headers
          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)
          expect(json['data'].length).to eq(barcodes.length)
          expect(json['data'][0]["attributes"]["barcode"]).to eq barcodes[0]
          expect(json['data'][1]["attributes"]["barcode"]).to eq barcodes[1]
        end
      end
    end

    describe 'filter and include' do
      context 'when including material and the material is a request' do
        let(:tubes_with_request) { create_list(pipeline_tube_request_factory, 2)}

        it 'returns the request data' do
          tube = tubes_with_request[0]
          get "#{send(tubes_path)}?filter[barcode]=#{tube.barcode}&include=material", headers: json_api_headers

          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)

          expect(json['data'].length).to eq(1)

          expect(json['included'][0]['id']).to eq tube.material.id.to_s
          expect(json['included'][0]['type']).to eq "requests"

          expect(json['included'][0]['attributes']['external_study_id']).to eq tube.material.external_study_id
          expect(json['included'][0]['attributes']['sample_name']).to eq tube.material.sample.name
          expect(json['included'][0]['attributes']['barcode']).to eq tube.barcode
          expect(json['included'][0]['attributes']['sample_species']).to eq tube.material.sample.species
          expect(json['included'][0]['attributes']['created_at']).to eq tube.material.sample.created_at.strftime('%m/%d/%Y %I:%M')

          expect(json['data'][0]['relationships']['material']['data']['type']).to eq 'requests'
          expect(json['data'][0]['relationships']['material']['data']['id'].to_s).to eq tube.material.id.to_s
        end
      end

      context 'when including material and the material is a library' do
        let(:tubes_with_library) { create_list(pipeline_tube_library_factory, 2)}

        it 'returns the request data' do
          tube = tubes_with_library[0]
          get "#{send(tubes_path)}?filter[barcode]=#{tube.barcode}&include=material", headers: json_api_headers

          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)

          expect(json['data'].length).to eq(1)

          expect(json['included'][0]['id']).to eq tube.material.id.to_s
          expect(json['included'][0]['type']).to eq "libraries"

          expect(json['data'][0]['attributes']['barcode']).to eq tube.barcode

          expect(json['data'][0]['relationships']['material']['data']['type']).to eq 'libraries'
          expect(json['data'][0]['relationships']['material']['data']['id'].to_s).to eq tube.material.id.to_s
        end
      end
    end
  end
end
