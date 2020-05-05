# frozen_string_literal: true

require "rails_helper"

RSpec.describe 'GraphQL', type: :request do
  context 'get libraries' do
    it 'returns empty array when no libraries exist' do
      post v2_path, params: { query: '{ ontLibraries { id } }' }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['ontLibraries']).to be_empty
    end

    it 'returns all libraries when many exist' do
      create_list(:ont_library, 3)
      post v2_path, params: { query: '{ ontLibraries { id } }' }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['ontLibraries'].length).to eq(3)
    end
  end

  context 'create libraries' do
    def valid_query
      <<~GQL
      mutation {
        createOntLibraries(
          input: {
            arguments: {
              plateBarcode: "PLATE-1234"
              tagSetName: "Test Tag Set"
              wellPrimaryGroupingDirection: "row"
            }
          }
        )
        {
          tubes { barcode materials { ... on Library { name pool wellRange poolSize } } }
          errors
        }
      }
      GQL
    end

    it 'creates tubes with libraries with provided parameters' do
      libraries = create_list(:ont_library_in_tube, 4).each_with_index do |library, i|
        library.pool = i+1
        library.name = "PLATE-1-1234-#{i+1}"
        library.well_range = "A#{(i*2)+1}-H#{(i+1)*2}"
        library.save
      end

      allow_any_instance_of(Ont::LibraryFactory).to receive(:save).and_return(true)
      allow_any_instance_of(Ont::LibraryFactory).to receive(:tubes).and_return(Tube.all)

      post v2_path, params: { query: valid_query }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      mutation_json = json['data']['createOntLibraries']
      tubes_json = mutation_json['tubes']

      expect(tubes_json[0]['barcode']).to eq('TRAC-2-1')
      expect(tubes_json[0]['materials']).to contain_exactly(
        { 'name' => 'PLATE-1-1234-1', 'pool' => 1, 'wellRange' => 'A1-H2', 'poolSize' => 24 }
      )

      expect(tubes_json[1]['barcode']).to eq('TRAC-2-2')
      expect(tubes_json[1]['materials']).to contain_exactly(
        { 'name' => 'PLATE-1-1234-2', 'pool' => 2, 'wellRange' => 'A3-H4', 'poolSize' => 24 }
      )

      expect(tubes_json[2]['barcode']).to eq('TRAC-2-3')
      expect(tubes_json[2]['materials']).to contain_exactly(
        { 'name' => 'PLATE-1-1234-3', 'pool' => 3, 'wellRange' => 'A5-H6', 'poolSize' => 24 }
      )

      expect(tubes_json[3]['barcode']).to eq('TRAC-2-4')
      expect(tubes_json[3]['materials']).to contain_exactly(
        { 'name' => 'PLATE-1-1234-4', 'pool' => 4, 'wellRange' => 'A7-H8', 'poolSize' => 24 }
      )

      expect(mutation_json['errors']).to be_empty
    end

    it 'responds with errors provided by the request factory' do
      errors = ActiveModel::Errors.new(Ont::LibraryFactory.new)
      errors.add('libraries', message: 'This is a test error')

      allow_any_instance_of(Ont::LibraryFactory).to receive(:save).and_return(false)
      allow_any_instance_of(Ont::LibraryFactory).to receive(:errors).and_return(errors)

      post v2_path, params: { query: valid_query }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      mutation_json = json['data']['createOntLibraries']
      expect(mutation_json['tubes']).to be_empty
      expect(mutation_json['errors']).to contain_exactly('Libraries {:message=>"This is a test error"}')
    end

    def missing_required_fields_query
      'mutation { createOntLibraries(input: { arguments: { bogus: "data" } } ) }'
    end

    it 'provides an error when missing required fields' do
      post v2_path, params: { query: missing_required_fields_query }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['errors']).not_to be_empty
    end
  end
end
