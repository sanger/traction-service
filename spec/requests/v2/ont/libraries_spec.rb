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

    it 'returns single library when one exists' do
      create(:ont_library)
      allow_any_instance_of(Ont::Library).to receive(:tube_barcode).and_return('test tube barcode')
      post v2_path, params: { query: '{ ontLibraries { name plateBarcode pool poolSize tubeBarcode } }' }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['ontLibraries']).to contain_exactly(
        { 'name' => 'PLATE-1-123456-2', 'plateBarcode' => 'PLATE-1-123456', 'pool' => 2,
          'poolSize' => 24, 'tubeBarcode' => 'test tube barcode'})
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
        createCovidLibraries(
          input: {
            arguments: {
              plateBarcode: "PLATE-1234"
            }
          }
        )
        {
          tubes { barcode materials { ... on Library { name pool poolSize } } }
          errors
        }
      }
      GQL
    end

    it 'creates tubes with libraries with provided parameters' do
      libraries = create(:ont_library_in_tube)

      allow_any_instance_of(Ont::LibraryFactory).to receive(:save).and_return(true)
      allow_any_instance_of(Ont::LibraryFactory).to receive(:tube).and_return(Tube.first)

      post v2_path, params: { query: valid_query }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      mutation_json = json['data']['createCovidLibraries']
      tubes_json = mutation_json['tubes']

      expect(tubes_json[0]['barcode']).to be_present
      expect(tubes_json[0]['materials']).to contain_exactly(
        { 'name' => 'PLATE-1-123456-2', 'pool' => 2, 'poolSize' => 24 }
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

      mutation_json = json['data']['createCovidLibraries']
      expect(mutation_json['tubes']).to be_nil
      expect(mutation_json['errors']).to contain_exactly('Libraries {:message=>"This is a test error"}')
    end

    def missing_required_fields_query
      'mutation { createCovidLibraries(input: { arguments: { bogus: "data" } } ) }'
    end

    it 'provides an error when missing required fields' do
      post v2_path, params: { query: missing_required_fields_query }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['errors']).not_to be_empty
    end
  end

  context 'delete library' do
    let!(:library) { create(:ont_library) } 

    def validQuery
      <<~GQL
      mutation {
        deleteCovidLibrary(
          input: {
            arguments: {
              plateBarcode: "PLATE-1234"
            }
          }
        )
        {
          tubes { barcode materials { ... on Library { name pool poolSize } } }
          errors
        }
      }
      GQL
    end

    it 'returns false with errors if library does not exist' do

    end

    it 'provides an error when missing required fields' do

    end

    context 'with flowcell' do
      it 'returns false with errors' do
      end

      it 'does not delete library' do
      end

      it 'does not delete tube' do
      end
    end

    context 'without flowcell' do
      it 'returns true with no errors on success' do

      end

      it 'returns false with errors if library deletion fails' do

      end

      it 'does not delete tube if library deletion fails' do

      end

      it 'returns false with errors if tube deletion fails' do

      end

      it 'does not delete library if tube deletion fails' do

      end
    end
  end
end
