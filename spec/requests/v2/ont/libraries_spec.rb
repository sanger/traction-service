# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphQL', type: :request do
  context 'get libraries' do
    it 'returns empty array when no libraries exist' do
      post v2_path, params: { query: '{ ontLibraries { id } }' }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['ontLibraries']).to be_empty
    end

    it 'returns single library when one exists' do
      library = create(:ont_library)
      allow_any_instance_of(Ont::Library).to receive(:tube_barcode).and_return('test tube barcode')
      post v2_path, params: { query:
        '{ ontLibraries { name plateBarcode pool poolSize tubeBarcode } }' }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['ontLibraries']).to contain_exactly(
        { 'name' => library.name, 'plateBarcode' => library.plate_barcode, 'pool' => library.pool,
          'poolSize' => 24, 'tubeBarcode' => 'test tube barcode' }
      )
    end

    it 'returns all libraries when many exist' do
      create_list(:ont_library, 3)
      post v2_path, params: { query: '{ ontLibraries { id } }' }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['ontLibraries'].length).to eq(3)
    end

    it 'returns all libraries when many exist and some are loaded in a flowcell' do
      create_list(:ont_library, 3)
      run = create(:ont_run)
      post v2_path, params: { query: '{ ontLibraries { id } }' }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['ontLibraries'].length).to eq(3 + run.flowcells.count)
    end

    it 'returns only unassigned libraries when many exist and some are loaded in a flowcell' do
      create_list(:ont_library, 3)
      run = create(:ont_run_with_flowcells)
      post v2_path, params: { query: '{ ontLibraries(unassignedToFlowcells: true) { id } }' }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(run.flowcells.count).to be > 0
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
      library = create(:ont_library_in_tube)

      allow_any_instance_of(Ont::LibraryFactory).to receive(:save).and_return(true)
      allow_any_instance_of(Ont::LibraryFactory).to receive(:tube).and_return(Tube.first)

      post v2_path, params: { query: valid_query }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      mutation_json = json['data']['createOntLibraries']
      tubes_json = mutation_json['tubes']

      expect(tubes_json[0]['barcode']).to be_present
      expect(tubes_json[0]['materials']).to contain_exactly(
        { 'name' => library.name, 'pool' => library.pool, 'poolSize' => 24 }
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
      expect(mutation_json['tubes']).to be_nil
      expect(mutation_json['errors']).to contain_exactly(
        'Libraries {:message=>"This is a test error"}'
      )
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

  context 'delete library' do
    def valid_query(library_name)
      <<~GQL
        mutation {
          deleteOntLibrary( input: { libraryName: "#{library_name}" } ) { success errors }
        }
      GQL
    end

    def missing_required_fields_query
      'mutation { deleteCovidLibrary (input: { bogus: "data" } ) }'
    end

    it 'returns false with errors if library does not exist' do
      post v2_path, params: { query: valid_query('library does not exist') }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      mutation_json = json['data']['deleteOntLibrary']
      expect(mutation_json['success']).to be_falsey
      expect(mutation_json['errors']).not_to be_empty
    end

    it 'provides an error when missing required fields' do
      post v2_path, params: { query: missing_required_fields_query }
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['errors']).not_to be_empty
    end

    context 'with flowcell' do
      it 'returns false with errors' do
        flowcell = create(:ont_flowcell)
        post v2_path, params: { query: valid_query(flowcell.library.name) }
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        mutation_json = json['data']['deleteOntLibrary']
        expect(mutation_json['success']).to be_falsey
        expect(mutation_json['errors']).not_to be_empty
      end

      it 'does not delete library' do
        flowcell = create(:ont_flowcell)
        # sanity check
        expect(Ont::Library.count).to eq(1)

        # post and test
        post v2_path, params: { query: valid_query(flowcell.library.name) }
        expect(response).to have_http_status(:success)
        expect(Ont::Library.count).to eq(1)
      end

      it 'does not delete tube' do
        flowcell_with_tube = create(:ont_flowcell, library: create(:ont_library_in_tube))
        # sanity check
        expect(Tube.count).to eq(1)

        # post and test
        post v2_path, params: { query: valid_query(flowcell_with_tube.library.name) }
        expect(response).to have_http_status(:success)
        expect(Tube.count).to eq(1)
      end
    end

    context 'without flowcell' do
      context 'without tube' do
        it 'returns true with no errors on success' do
          library = create(:ont_library)
          post v2_path, params: { query: valid_query(library.name) }
          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)
          mutation_json = json['data']['deleteOntLibrary']
          expect(mutation_json['success']).to be_truthy
          expect(mutation_json['errors']).to be_empty
        end

        it 'deletes library on success' do
          library = create(:ont_library)
          # sanity check
          expect(Ont::Library.count).to eq(1)

          # post and test
          post v2_path, params: { query: valid_query(library.name) }
          expect(response).to have_http_status(:success)
          expect(Ont::Library.count).to eq(0)
        end

        it 'returns false with errors if library deletion fails' do
          # mock error destroying library
          library = create(:ont_library)
          error_message = 'this is a test error'
          error = ActiveRecord::RecordNotDestroyed.new(error_message, library)
          allow_any_instance_of(Ont::Library).to receive(:destroy!).and_raise(error)

          # post and test
          post v2_path, params: { query: valid_query(library.name) }
          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)
          mutation_json = json['data']['deleteOntLibrary']
          expect(mutation_json['success']).to be_falsey
          expect(mutation_json['errors']).to contain_exactly(error_message)
        end
      end

      context 'with tube' do
        it 'returns true with no errors on success' do
          library = create(:ont_library_in_tube)
          post v2_path, params: { query: valid_query(library.name) }
          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)
          mutation_json = json['data']['deleteOntLibrary']
          expect(mutation_json['success']).to be_truthy
          expect(mutation_json['errors']).to be_empty
        end

        it 'deletes library on success' do
          library = create(:ont_library_in_tube)
          # sanity check
          expect(Ont::Library.count).to eq(1)

          # post and test
          post v2_path, params: { query: valid_query(library.name) }
          expect(response).to have_http_status(:success)
          expect(Ont::Library.count).to eq(0)
        end

        it 'deletes tube on success' do
          library = create(:ont_library_in_tube)
          # sanity check
          expect(Tube.count).to eq(1)
          expect(ContainerMaterial.count).to eq(1)

          # post and test
          post v2_path, params: { query: valid_query(library.name) }
          expect(response).to have_http_status(:success)
          expect(Tube.count).to eq(0)
          expect(ContainerMaterial.count).to eq(0)
        end

        it 'returns false with errors if library deletion fails' do
          # mock error destroying library
          library = create(:ont_library_in_tube)
          error_message = 'this is a test error'
          error = ActiveRecord::RecordNotDestroyed.new(error_message, library)
          allow_any_instance_of(Ont::Library).to receive(:destroy!).and_raise(error)

          # post and test
          post v2_path, params: { query: valid_query(library.name) }
          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)
          mutation_json = json['data']['deleteOntLibrary']
          expect(mutation_json['success']).to be_falsey
          expect(mutation_json['errors']).to contain_exactly(error_message)
        end

        it 'does not delete tube if library deletion fails' do
          # mock error destroying library
          library = create(:ont_library_in_tube)
          error_message = 'this is a test error'
          error = ActiveRecord::RecordNotDestroyed.new(error_message, library)
          allow_any_instance_of(Ont::Library).to receive(:destroy!).and_raise(error)

          # sanity check
          expect(Tube.count).to eq(1)
          expect(ContainerMaterial.count).to eq(1)

          # post and test
          post v2_path, params: { query: valid_query(library.name) }
          expect(response).to have_http_status(:success)
          expect(Tube.count).to eq(1)
          expect(ContainerMaterial.count).to eq(1)
        end

        it 'returns false with errors if tube deletion fails' do
          # mock error destroying tube
          library = create(:ont_library_in_tube)
          error_message = 'this is a test error'
          error = ActiveRecord::RecordNotDestroyed.new(error_message, library.container)
          allow_any_instance_of(Tube).to receive(:destroy!).and_raise(error)

          # post and test
          post v2_path, params: { query: valid_query(library.name) }
          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)
          mutation_json = json['data']['deleteOntLibrary']
          expect(mutation_json['success']).to be_falsey
          expect(mutation_json['errors']).to contain_exactly(error_message)
        end

        it 'does not delete library if tube deletion fails' do
          # mock error destroying tube
          library = create(:ont_library_in_tube)
          error_message = 'this is a test error'
          error = ActiveRecord::RecordNotDestroyed.new(error_message, library.container)
          allow_any_instance_of(Tube).to receive(:destroy!).and_raise(error)

          # sanity check
          expect(Ont::Library.count).to eq(1)

          # post and test
          post v2_path, params: { query: valid_query(library.name) }
          expect(response).to have_http_status(:success)
          expect(Ont::Library.count).to eq(1)
        end
      end
    end
  end
end
