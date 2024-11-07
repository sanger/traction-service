# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::LibraryBatch, :pacbio do
  it 'is valid with valid attributes' do
    library_batch = build(:pacbio_library_batch)
    expect(library_batch).to be_valid
  end

  it 'is not valid without libraries' do
    library_batch = build(:pacbio_library_batch, libraries: [])
    expect(library_batch).not_to be_valid
    expect(library_batch.errors[:libraries]).to include("can't be blank")
  end

  it 'nullifies associated libraries on destroy' do
    library_batch = create(:pacbio_library_batch)
    library = create(:pacbio_library, library_batch: library_batch)
    library_batch.destroy
    expect(library.reload.library_batch).to be_nil
  end

  describe 'creating nested libraries' do
    define_negated_matcher :not_change, :change

    let(:pacbio_requests_enum) { create_list(:pacbio_request, 8).cycle }
    let(:pacbio_libraries) { build_list(:pacbio_library, 8, pacbio_request_id: pacbio_requests_enum.next.id) }
    # Creates valid attributes for the libraries - including the primary aliquot attributes and a pacbio_request_id
    let(:libraries_attributes) do
      pacbio_libraries.map do |lib|
        { **lib.attributes, primary_aliquot_attributes: lib.primary_aliquot.attributes, pacbio_request_id: lib.request.id }
      end
    end

    it 'accepts nested attributes for libraries' do
      library_batch = described_class.new(libraries_attributes: libraries_attributes)
      expect { library_batch.save! }.to change(Pacbio::Library, :count).by(8)
      expect(library_batch.libraries.count).to eq(8)
    end

    it 'does not save the library batch if a library is invalid' do
      # Make the last library invalid
      libraries_attributes.last[:pacbio_request_id] = nil

      library_batch = described_class.new(libraries_attributes: libraries_attributes)
      expect { library_batch.save! }.to raise_error(ActiveRecord::RecordInvalid).and not_change(Pacbio::Library, :count)
      expect(library_batch.errors['libraries.request']).to include('must exist')
    end
  end
end
