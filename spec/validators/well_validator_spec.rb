# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WellValidator do
  describe '#validate' do
    let(:well) { build(:pacbio_well, library_count: 0, pool_count: 0) }

    context 'invalid' do
      it 'returns an error when there are multiple aliquots but no tags' do
        well.used_aliquots = build_list(:aliquot, 5, source: build(:pacbio_library, :untagged), aliquot_type: :derived)
        well.valid?
        expect(well.errors[:tags]).to include('are missing from the libraries')
      end

      it 'returns an error when there are multiple libraries and some tags are missing' do
        well.used_aliquots = build_list(:aliquot, 5, source: build(:pacbio_library, :untagged), aliquot_type: :derived)
        well.used_aliquots += build_list(:aliquot, 5, source: build(:pacbio_pool, :tagged), aliquot_type: :derived)
        well.valid?
        expect(well.errors[:tags]).to include('are missing from the libraries')
      end

      it 'returns an error when there are multiple libraries and some tags are not unique' do
        tag = create(:tag)
        well.used_aliquots = build_list(:aliquot, 5, source: build(:pacbio_library, :tagged), aliquot_type: :derived)
        aliquot1 = create(:aliquot, source: create(:pacbio_library, tag:))
        aliquot2 = create(:aliquot, source: create(:pacbio_library, tag:))
        well.used_aliquots += [aliquot1, aliquot2]
        well.valid?
        expect(well.errors[:tags]).to include("are not unique within the libraries for well #{well.position}")
      end
    end

    context 'valid' do
      it 'is valid aliquots are empty' do
        well.used_aliquots = []
        well.valid?
        expect(well.errors[:base]).to be_empty
      end

      it 'is valid when there are multiple libraries and all have unique tags' do
        aliquot1 = create(:aliquot, tag: create(:tag), source: create(:pacbio_library))
        aliquot2 = create(:aliquot, tag: create(:tag), source: create(:pacbio_library))
        well.used_aliquots = [aliquot1, aliquot2]
        well.valid?
        expect(well.errors[:tags]).to be_empty
      end

      it 'is valid when there is one library that is untagged' do
        aliquot1 = create(:aliquot, tag: nil, source: create(:pacbio_library))
        aliquot2 = create(:aliquot, tag: create(:tag), source: create(:pacbio_library))
        well.used_aliquots = [aliquot1, aliquot2]
        well.valid?
        expect(well.errors[:tags]).to be_empty
      end
    end
  end
end
