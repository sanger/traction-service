# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::LibraryFactory, type: :model, pacbio: true do

  let(:tags)                    { create_list(:tag, 3) }
  let(:requests)                { create_list(:pacbio_request, 3) }
  let(:request_attributes)      {[
                                  {id: requests[0].id, type: 'requests', tag: { id: tags[0].id, type: 'tags'}},
                                  {id: requests[1].id, type: 'requests', tag: { id: tags[1].id, type: 'tags'}}
                                ]}
  let(:libraries_attributes)    { attributes_for(:pacbio_library).merge(requests: request_attributes) }

  context 'LibraryFactory' do
    context '#initialize' do
      before do
        @factory = Pacbio::LibraryFactory.new(libraries_attributes)
        @pacbio_library = @factory.library
      end

      it 'creates a Pacbio::Library object' do
        expect(@pacbio_library.volume).to be_present
        expect(@pacbio_library.concentration).to be_present
        expect(@pacbio_library.library_kit_barcode).to be_present
        expect(@pacbio_library.fragment_size).to be_present
        expect(@pacbio_library.id).to be_nil
        expect(@pacbio_library.created_at).to be_nil
        expect(@pacbio_library.updated_at).to be_nil
        expect(@pacbio_library.state).to be_nil
      end
    end

    context '#request_libraries' do
      it 'creates a list of LibraryFactory::RequestLibraries' do
        factory = Pacbio::LibraryFactory.new(libraries_attributes)
        factory_request_libraries = factory.request_libraries
        expect(factory_request_libraries.class).to eq Pacbio::LibraryFactory::RequestLibraries
        expect(factory_request_libraries.request_libraries.length).to eq 2
      end
    end

    context '#save' do
      context 'when valid' do
        before do
          @factory = Pacbio::LibraryFactory.new(libraries_attributes)
          @factory.save
        end

        it 'can save' do
          expect(@factory).to be_valid
        end

        it 'creates a Pacbio::Library' do
          library = @factory.library
          expect(library.id).to be_present
          expect(library.id).not_to be_nil
          expect(library.created_at).not_to be_nil
          expect(library.updated_at).not_to be_nil
          expect(library.state).not_to be_nil
        end

        it 'creates a Tube' do
          tube = @factory.library.tube
          expect(tube.id).not_to be_nil
          expect(tube.barcode).not_to be_nil
          expect(tube.materials.first.id).to eq @factory.library.id
          expect(tube.created_at).to be_present
          expect(tube.updated_at).to be_present
        end

        it 'associates the list of Pacbio::RequestLibrary(s) and tags, with the Pacbio::Library' do
          library = @factory.library
          request_libraries = library.request_libraries
          expect(request_libraries.length).to eq 2
          expect(request_libraries[0].class).to eq Pacbio::RequestLibrary
          expect(request_libraries[1].class).to eq Pacbio::RequestLibrary
          expect(request_libraries[0].id).to be_present
          expect(request_libraries[1].id).to be_present
          expect(request_libraries[0].pacbio_request_id).to eq requests[0].id
          expect(request_libraries[1].pacbio_request_id).to eq requests[1].id
          expect(request_libraries[0].pacbio_library_id).to eq library.id
          expect(request_libraries[1].pacbio_library_id).to eq library.id
          expect(request_libraries[0].tag_id).to eq tags[0].id
          expect(request_libraries[1].tag_id).to eq tags[1].id
        end

      end

      context 'when invalid' do
        context 'when the library is invalid' do
          it 'produces error messages if the library is missing a required attribute' do
            invalid_library_attributes = attributes_for(:pacbio_library).except(:volume).merge(requests: request_attributes)
            factory = Pacbio::LibraryFactory.new(invalid_library_attributes)
            expect(factory.save).to be_falsy
            expect(factory.errors.full_messages).to include "Volume can't be blank"
          end
        end

        context 'when the request libraries are invalid' do
          let(:request_empty_cost_code) { create(:pacbio_request, cost_code: "")}
          let(:request_nil_cost_code) { create(:pacbio_request, cost_code: nil)}

          it 'produces an error if there is more than one request and a tag is missing' do
            invalid_request_attributes = [{id: requests[0].id, type: 'requests'}, {id: requests[1].id, type: 'requests', tag: { id: tags[0].id, type: 'tags'}}]
            library_attributes = attributes_for(:pacbio_library).merge(requests: invalid_request_attributes)

            factory = Pacbio::LibraryFactory.new(library_attributes)
            expect(factory.valid?).to be_falsy
            expect(factory.errors.full_messages).to eq ['Tag must be present']
          end

          it 'produces an error if there is more than one request and two tags are the same' do
            invalid_request_attributes = [{ id: requests[0].id, type: 'requests', tag: { id: tags[0].id, type: 'tags' } },
                                          { id: requests[1].id, type: 'requests', tag: { id: tags[0].id, type: 'tags' } }]
            library_attributes = attributes_for(:pacbio_library).merge(requests: invalid_request_attributes)

            factory = Pacbio::LibraryFactory.new(library_attributes)
            expect(factory.valid?).to be_falsy
            expect(factory.errors.full_messages).to eq(['Tag is used more than once'])
          end

          it 'produces an error if any request contains an empty cost code' do
            invalid_request_attributes = [{id: request_empty_cost_code.id, type: 'requests', tag: { id: tags[0].id, type: 'tags'} }]
            library_attributes = attributes_for(:pacbio_library).merge(requests: invalid_request_attributes)

            factory = Pacbio::LibraryFactory.new(library_attributes)
            expect(factory.valid?).to be_falsy
            expect(factory.errors.full_messages).to eq(['Cost code must be present'])
          end

          it 'produces an error if any request contains a nil cost code' do
            invalid_request_attributes = [{id: request_nil_cost_code.id, type: 'requests', tag: { id: tags[0].id, type: 'tags'} }]
            library_attributes = attributes_for(:pacbio_library).merge(requests: invalid_request_attributes)

            factory = Pacbio::LibraryFactory.new(library_attributes)
            expect(factory.valid?).to be_falsy
            expect(factory.errors.full_messages).to eq(['Cost code must be present'])
          end

          it 'produces an error if any two requests in a library are the same' do
            invalid_request_attributes = [
              {id: requests[0].id, type: 'requests', tag: { id: tags[0].id, type: 'tags'}},
              {id: requests[0].id, type: 'requests', tag: { id: tags[1].id, type: 'tags'}}
            ]
            library_attributes = attributes_for(:pacbio_library).merge(requests: invalid_request_attributes)
            factory = Pacbio::LibraryFactory.new(library_attributes)
            expect(factory.valid?).to be_falsy
            expect(factory.errors.full_messages).to eq(['Request is used more than once'])
          end
        end
      end

      context 'when save errors' do
        before do
          @factory = Pacbio::LibraryFactory.new(attributes)
          allow(@factory).to receive(:valid?).and_return true
        end

        context 'when the library fails to save' do
          let(:attributes) { attributes_for(:pacbio_library).except(:volume).merge(requests: request_attributes)}

          it 'doesnt create a library' do
            expect { @factory.save }.not_to change(Pacbio::Library, :count)
          end

          it 'doesnt create the request libraries' do
            expect { @factory.save }.not_to change(Pacbio::RequestLibrary, :count)
          end
        end

        context 'when the request libraries fail to save' do
          before do
            allow(@factory.request_libraries).to receive(:save).and_return false
          end

          let(:attributes) { attributes_for(:pacbio_library).merge(requests: [{id: requests[0].id, type: 'requests'}] ) }

          it 'doesnt create the request libraries' do
            expect { @factory.save }.not_to change(Pacbio::RequestLibrary, :count)
          end
        end
      end
    end

    context '#id' do
      it 'returns the Pacbio::Library id' do
        factory = Pacbio::LibraryFactory.new(libraries_attributes)
        factory.save
        library = factory.library
        expect(factory.id).to eq library.id
      end
    end
  end

  context 'LibraryFactory::RequestLibraries' do
    let(:library) { build(:pacbio_library) }

    context '#initialize' do
      before do
        @factory = Pacbio::LibraryFactory::RequestLibraries.new(library, request_attributes)
      end

      it 'has a library' do
        expect(@factory.library).to eq library
      end

      it 'creates a list of Pacbio::RequestLibrary for the librarys request libraries with their tag' do
        pacbio_request_libraries = @factory.request_libraries
        expect(pacbio_request_libraries[0].class).to eq Pacbio::RequestLibrary
        expect(pacbio_request_libraries[0].class).to eq Pacbio::RequestLibrary
        expect(pacbio_request_libraries.length).to eq 2
        expect(pacbio_request_libraries[0].pacbio_request_id).to eq requests[0].id
        expect(pacbio_request_libraries[1].pacbio_request_id).to eq requests[1].id
        expect(pacbio_request_libraries[0].pacbio_library_id).to be_nil
        expect(pacbio_request_libraries[1].pacbio_library_id).to be_nil
        expect(pacbio_request_libraries[0].tag_id).to eq tags[0].id
        expect(pacbio_request_libraries[1].tag_id).to eq tags[1].id
      end
    end

    context '#save' do
      before do
        @factory = Pacbio::LibraryFactory::RequestLibraries.new(library, request_attributes)
      end

      it 'associates the request libraries with the library' do
        library.save
        pacbio_request_libraries = @factory.request_libraries
        @factory.save
        expect(library.request_libraries).to eq pacbio_request_libraries
        expect(library.request_libraries[0].pacbio_library_id).to eq library.id
        expect(library.request_libraries[1].pacbio_library_id).to eq library.id
      end
    end
  end

end
