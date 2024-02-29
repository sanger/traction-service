# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WellValidator do
  describe '#validate' do
    let(:well) { build(:pacbio_well) }

    context 'invalid' do
      it 'returns an error when there are no libraries or pools' do
        well.libraries = []
        well.pools = []
        well.valid?
        expect(well.errors[:base]).to include("There must be at least 1 pool or library for well #{well.position}")
      end

      it 'returns an error when there are multiple libraries but no tags' do
        well.pools = []
        well.libraries = create_list(:pacbio_library, 2, :untagged)
        well.valid?
        expect(well.errors[:tags]).to include('are missing from the libraries')
      end

      it 'returns an error when there are multiple libraries and some tags are missing' do
        well.pools = [create(:pacbio_pool, :tagged)]
        well.libraries = [create(:pacbio_library, :untagged), create(:pacbio_library, :tagged)]
        well.valid?
        expect(well.errors[:tags]).to include('are missing from the libraries')
      end

      it 'returns an error when there are multiple libraries and some tags are not unique' do
        tag = create(:tag)
        well.pools = [create(:pacbio_pool, :tagged)]
        well.libraries = create_list(:pacbio_library, 2, tag:)
        well.valid?
        expect(well.errors[:tags]).to include("are not unique within the libraries for well #{well.position}")
      end
    end

    context 'valid' do
      it 'is valid when pools are empty but there are libraries' do
        well.pools = []
        well.libraries = [create(:pacbio_library)]
        well.valid?
        expect(well.errors[:base]).to be_empty
      end

      it 'is valid when libraries are empty but there are pools' do
        well.pools = [create(:pacbio_pool)]
        well.libraries = []
        well.valid?
        expect(well.errors[:base]).to be_empty
      end

      it 'is valid when there are multiple libraries and all have unique tags' do
        well.pools = [create(:pacbio_pool, :tagged)]
        well.libraries = create_list(:pacbio_library, 2, :tagged)
        well.valid?
        expect(well.errors[:tags]).to be_empty
      end

      it 'is valid when there is one library that is untagged' do
        well.pools = []
        well.libraries = [create(:pacbio_library, :untagged)]
        well.valid?
        expect(well.errors[:tags]).to be_empty
      end
    end
  end
end
