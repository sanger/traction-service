# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WellValidator do
  describe '#validate' do
    let(:well) { build(:pacbio_well, library_count: 0, pool_count: 0) }

    context 'invalid' do
      it 'returns an error when there are no libraries or pools' do
        well.valid?
        expect(well.errors[:base]).to include("There must be at least 1 pool or library for well #{well.position}")
      end

      it 'returns an error when there are multiple libraries but no tags' do
        # Going through the library_ids= method to create the aliquots
        well.library_ids = create_list(:pacbio_library, 2, :untagged).collect(&:id)
        well.valid?
        expect(well.errors[:tags]).to include('are missing from the libraries')
      end

      it 'returns an error when there are multiple libraries and some tags are missing' do
        well.pool_ids = [create(:pacbio_pool, :tagged)].collect(&:id)
        well.library_ids = [create(:pacbio_library, :untagged), create(:pacbio_library, :tagged)].collect(&:id)
        well.valid?
        expect(well.errors[:tags]).to include('are missing from the libraries')
      end

      it 'returns an error when there are multiple libraries and some tags are not unique' do
        tag = create(:tag)
        well.pool_ids = [create(:pacbio_pool, :tagged)].collect(&:id)
        well.library_ids = create_list(:pacbio_library, 2, tag:).collect(&:id)
        well.valid?
        expect(well.errors[:tags]).to include("are not unique within the libraries for well #{well.position}")
      end
    end

    context 'valid' do
      it 'is valid when pools are empty but there are libraries' do
        well.library_ids = [create(:pacbio_library)].collect(&:id)
        well.valid?
        expect(well.errors[:base]).to be_empty
      end

      it 'is valid when libraries are empty but there are pools' do
        well.pool_ids = [create(:pacbio_pool)].collect(&:id)
        well.valid?
        expect(well.errors[:base]).to be_empty
      end

      it 'is valid when there are multiple libraries and all have unique tags' do
        well.pool_ids = [create(:pacbio_pool, :tagged)].collect(&:id)
        well.library_ids = create_list(:pacbio_library, 2, :tagged).collect(&:id)
        well.valid?
        expect(well.errors[:tags]).to be_empty
      end

      it 'is valid when there is one library that is untagged' do
        well.library_ids = [create(:pacbio_library, :untagged)].collect(&:id)
        well.valid?
        expect(well.errors[:tags]).to be_empty
      end
    end
  end
end
