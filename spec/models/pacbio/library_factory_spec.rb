# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::LibraryFactory, pacbio: true do
  let(:tags)                    { create_list(:tag, 3) }
  let(:requests)                { create_list(:pacbio_request, 3) }
  let(:request_attributes)      do
    [{ id: requests[0].id, type: 'requests', tag: { id: tags[0].id, type: 'tags' } }]
  end

  let(:libraries_attributes) do
    attributes_for(:pacbio_library).except(:request, :tag)
                                   .merge(pacbio_request_id: requests[0].id, tag_id: tags[0].id)
  end

  context 'LibraryFactory' do
    describe '#initialize' do
      subject(:factory) { described_class.new(libraries_attributes) }

      let(:pacbio_library) { factory.library }

      it 'creates a Pacbio::Library object', aggregate_failures: true do
        expect(pacbio_library.volume).to be_present
        expect(pacbio_library.concentration).to be_present
        expect(pacbio_library.template_prep_kit_box_barcode).to be_present
        expect(pacbio_library.insert_size).to be_present
        expect(pacbio_library.id).to be_nil
        expect(pacbio_library.created_at).to be_nil
        expect(pacbio_library.updated_at).to be_nil
        expect(pacbio_library.state).to be_nil
        expect(pacbio_library.request).to be_a(Pacbio::Request)
        expect(pacbio_library.pool).to be_a(Pacbio::Pool)
      end

      it 'populates to pool object with the library information', aggregate_failures: true do
        expect(pacbio_library.pool.volume).to eq pacbio_library.volume
        expect(pacbio_library.pool.concentration).to eq pacbio_library.concentration
        expect(pacbio_library.pool.template_prep_kit_box_barcode).to eq pacbio_library.template_prep_kit_box_barcode
        expect(pacbio_library.pool.insert_size).to eq pacbio_library.insert_size
      end
    end

    describe '#save' do
      context 'when valid' do
        subject(:factory) { described_class.new(libraries_attributes) }

        let(:library) { factory.library }

        before do
          factory.save
        end

        it 'can save' do
          expect(factory).to be_valid
        end

        it 'creates a Pacbio::Library' do
          expect(library.id).to be_present
          expect(library.created_at).to be_present
          expect(library.updated_at).to be_present
          expect(library.state).to be_present
        end

        it 'creates a Tube' do
          tube = factory.library.tube
          expect(tube.id).not_to be_nil
          expect(tube.barcode).not_to be_nil
          expect(tube.materials.first.id).to eq factory.library.id
          expect(tube.created_at).to be_present
          expect(tube.updated_at).to be_present
        end

        it 'associates the Pacbio::Request with the Pacbio::Library' do
          expect(library.request).to eq requests.first
        end

        it 'associated the Tag with the Pacbio::Library' do
          expect(library.tag_id).to eq tags[0].id
        end
      end

      context 'when invalid' do
        context 'when the library is invalid' do
          it 'produces error messages if the library is missing a required attribute' do
            invalid_library_attributes = libraries_attributes.merge(volume: 'elephant')
            factory = described_class.new(invalid_library_attributes)
            expect(factory.save).to be_falsy
            expect(factory.errors.full_messages).to include 'Volume is not a number'
          end
        end

        context 'when the request libraries are invalid' do
          let(:request_empty_cost_code) { create(:pacbio_request, cost_code: '') }
          let(:request_nil_cost_code) { create(:pacbio_request, cost_code: nil) }

          it 'produces an error if any request contains an empty cost code' do
            library_attributes = attributes_for(:pacbio_library).merge(pacbio_request_id: request_empty_cost_code.id)

            factory = described_class.new(library_attributes)
            expect(factory).not_to be_valid
            expect(factory.errors.full_messages).to eq(['Cost code must be present'])
          end

          it 'produces an error if any request contains a nil cost code' do
            library_attributes = attributes_for(:pacbio_library).merge(pacbio_request_id: request_nil_cost_code.id)

            factory = described_class.new(library_attributes)
            expect(factory).not_to be_valid
            expect(factory.errors.full_messages).to eq(['Cost code must be present'])
          end
        end
      end

      context 'when save errors' do
        subject(:factory) { described_class.new(attributes) }

        before do
          # This test seems to be designed to catch edge cases, in which problems that
          # slip past validation, and cause the factory to fail, should result in the
          # entire factory rolling back. It is achieving this by bypassing the standard
          # validation, thereby causing the model level validation to fail. However
          # the structure of this test is somewhat artificial, and doesn't really test
          # the behaviour we want.
          # https://github.com/sanger/traction-service/issues/753
          allow(factory).to receive(:valid?).and_return true # rubocop:todo RSpec/SubjectStub
        end

        context 'when the library fails to save' do
          let(:attributes) { attributes_for(:pacbio_library, volume: 'elephant') }

          it 'doesnt create a library' do
            expect { factory.save }.not_to change(Pacbio::Library, :count)
          end

          it 'doesnt create the requests' do
            expect { factory.save }.not_to change(Pacbio::Request, :count)
          end
        end
      end
    end

    describe '#id' do
      it 'returns the Pacbio::Library id' do
        factory = described_class.new(libraries_attributes)
        factory.save
        library = factory.library
        expect(factory.id).to eq library.id
      end
    end
  end
end
