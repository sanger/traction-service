# frozen_string_literal: true

require "rails_helper"

RSpec.describe 'GraphQL', type: :request do
  context 'get plates' do
    context 'when no plates' do
      it 'returns empty plates' do
        post v2_path, params: { query: '{ plates { id } }' }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['plates'].length).to eq(0)
      end
    end

    context 'when some plates' do
      let!(:plates) { create_list(:plate, 3) }

      it 'returns all plates' do
        post v2_path, params: { query: '{ plates { id } }' }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['plates'].length).to eq(3)
      end
    end

    context 'when there is a plate with samples' do
      let!(:plate) do
        create(:plate_with_ont_requests, wells: [
            { position: 'A1', requests: [ { name: 'Sample in A1', external_id: '1' } ] },
            { position: 'H12', requests: [ { name: 'Sample 1 in H12', external_id: '2' }, { name: 'Sample 2 in H12', external_id: '3' } ] }
          ])
      end

      it 'returns plate with nested sample' do
        post v2_path, params: { query: '{ plates { wells { materials { ... on Request { name } } } } }' }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['plates'].length).to eq(1)
        expect(json['data']['plates'].first).to include(
          'wells' => [
            {
              'materials' => [
                { 'name' => 'Sample in A1' }
              ]
            },
            {
              'materials' => [
                { 'name' => 'Sample 1 in H12' },
                { 'name' => 'Sample 2 in H12' }
              ]
            }
          ]
        )
      end
    end
  end

  context 'create plate' do
    def valid_query
      <<~GQL
      mutation {
        createPlateWithCovidSamples(
          input: {
            arguments: {
              barcode: "PLATE-1234"
              wells: [
                { position: "A1" sample: { name: "Sample for A1" externalId: "ExtIdA1-1" } }
                { position: "E7" sample: { name: "Sample for E7" externalId: "ExtIdE7" } }
              ]
            }
          }
        )
        {
          plate { barcode wells { materials { ... on Request { name externalId } } } }
          errors
        }
      }
      GQL
    end

    it 'creates a plate with provided parameters' do
      plate = create(:plate_with_ont_requests, barcode: 'PLATE-1234', wells: [
        { position: 'A1', requests: [ { name: 'Sample for A1', external_id: 'ExtIdA1-1' } ] },
        { position: 'E7', requests: [ { name: 'Sample for E7', external_id: 'ExtIdE7' } ] } ] )

      allow_any_instance_of(Ont::PlateFactory).to receive(:save).and_return(true)
      allow_any_instance_of(Ont::PlateFactory).to receive(:plate).and_return(plate)

      post v2_path, params: { query: valid_query }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      mutation_json = json['data']['createPlateWithCovidSamples']
      plate_json = mutation_json['plate']
      expect(plate_json['barcode']).to eq('PLATE-1234')

      expect(plate_json['wells'][0]['materials']).to contain_exactly(
        { 'name' => 'Sample for A1', 'externalId' => 'ExtIdA1-1' }
      )
      expect(plate_json['wells'][1]['materials']).to contain_exactly(
        { 'name' => 'Sample for E7', 'externalId' => 'ExtIdE7' }
      )
      expect(mutation_json['errors']).to be_empty
    end

    it 'responds with errors provided by the request factory' do
      errors = ActiveModel::Errors.new(Ont::PlateFactory.new)
      errors.add('wells', message: 'This is a test error')

      allow_any_instance_of(Ont::PlateFactory).to receive(:save).and_return(false)
      allow_any_instance_of(Ont::PlateFactory).to receive(:errors).and_return(errors)

      post v2_path, params: { query: valid_query }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      mutation_json = json['data']['createPlateWithCovidSamples']
      expect(mutation_json['plate']).to be_nil
      expect(mutation_json['errors']).to contain_exactly('Wells {:message=>"This is a test error"}')
    end

    def missing_required_fields_query
      'mutation { createPlateWithCovidSamples(input: { arguments: { bogus: "data" } } ) { plate { id } } }'
    end

    it 'provides an error when missing required fields' do
      post v2_path, params: { query: missing_required_fields_query }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['errors']).not_to be_empty
    end
  end
end
