# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::LibraryFactory, type: :model, pacbio: true do

  let(:tags)                    { create_list(:tag, 3) }
  let(:requests)                { create_list(:pacbio_request, 3) }
  let(:request_attributes)      do
    [{id: requests[0].id, type: 'requests', tag: { id: tags[0].id, type: 'tags'}}]
  end
  # TODO: This payload should be updated to reflect the single request nature of a library
  let(:libraries_attributes)    { attributes_for(:pacbio_library).except(:request, :tag).merge(requests: request_attributes) }

  context 'LibraryFactory' do
    context '#initialize' do
      before do
        @factory = Pacbio::LibraryFactory.new(libraries_attributes)
        @pacbio_library = @factory.library
      end

      it 'creates a Pacbio::Library object' do
        expect(@pacbio_library.volume).to be_present
        expect(@pacbio_library.concentration).to be_present
        expect(@pacbio_library.template_prep_kit_box_barcode).to be_present
        expect(@pacbio_library.fragment_size).to be_present
        expect(@pacbio_library.id).to be_nil
        expect(@pacbio_library.created_at).to be_nil
        expect(@pacbio_library.updated_at).to be_nil
        expect(@pacbio_library.state).to be_nil
        expect(@pacbio_library.request).to be_present
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
          expect(library.created_at).to be_present
          expect(library.updated_at).to be_present
          expect(library.state).to be_present
        end

        it 'creates a Tube' do
          tube = @factory.library.tube
          expect(tube.id).not_to be_nil
          expect(tube.barcode).not_to be_nil
          expect(tube.materials.first.id).to eq @factory.library.id
          expect(tube.created_at).to be_present
          expect(tube.updated_at).to be_present
        end

        it 'associates the Pacbio::Request with the Pacbio::Library' do
          library = @factory.library
          expect(library.request).to eq requests.first
        end

        it 'associated the Tag with the Pacbio::Library' do
          library = @factory.library
          expect(library.tag_id).to eq tags[0].id
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

          it 'doesnt create the requests' do
            expect { @factory.save }.not_to change(Pacbio::Request, :count)
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
end
