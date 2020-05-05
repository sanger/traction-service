# frozen_string_literal: true

require "rails_helper"

RSpec.describe 'GraphQL', type: :request do
  context 'create ont libraries' do
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
          libraries { plateBarcode pool wellRange poolSize }
          errors
        }
      }
      GQL
    end

    it 'creates libraries with provided parameters' do
      libraries = create_list(:ont_library, 4).each_with_index do |library, i|
        library.pool = i+1
        library.well_range = "A#{(i*2)+1}-H#{(i+1)*2}"
      end

      allow_any_instance_of(Ont::LibraryFactory).to receive(:save).and_return(true)
      allow_any_instance_of(Ont::LibraryFactory).to receive(:libraries).and_return(libraries)

      post v2_path, params: { query: valid_query }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      mutation_json = json['data']['createOntLibraries']
      libraries_json = mutation_json['libraries']

      expect(libraries_json[0]['plateBarcode']).to eq('PLATE-1-123456')
      expect(libraries_json[0]['pool']).to eq(1)
      expect(libraries_json[0]['wellRange']).to eq('A1-H2')
      expect(libraries_json[0]['poolSize']).to eq(24)

      expect(libraries_json[1]['plateBarcode']).to eq('PLATE-1-123456')
      expect(libraries_json[1]['pool']).to eq(2)
      expect(libraries_json[1]['wellRange']).to eq('A3-H4')
      expect(libraries_json[1]['poolSize']).to eq(24)

      expect(libraries_json[2]['plateBarcode']).to eq('PLATE-1-123456')
      expect(libraries_json[2]['pool']).to eq(3)
      expect(libraries_json[2]['wellRange']).to eq('A5-H6')
      expect(libraries_json[2]['poolSize']).to eq(24)

      expect(libraries_json[3]['plateBarcode']).to eq('PLATE-1-123456')
      expect(libraries_json[3]['pool']).to eq(4)
      expect(libraries_json[3]['wellRange']).to eq('A7-H8')
      expect(libraries_json[3]['poolSize']).to eq(24)
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
      expect(mutation_json['libraries']).to be_empty
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
