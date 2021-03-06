require 'rails_helper'

RSpec.describe Pacbio::Pool, type: :model, pacbio: true do

  let(:libraries) { create_list(:pacbio_library, 5) }

  it 'will have a tube' do
    tube = create(:tube)
    pool = build(:pacbio_pool, tube: tube)
    expect(pool.tube).to eq(tube)
  end

  it 'can have many libraries' do
    pool = build(:pacbio_pool, libraries: libraries)
    expect(pool.libraries).to eq(libraries)
  end

  it 'is not valid unless there is at least one library' do
    expect(build(:pacbio_pool, libraries: [])).to_not be_valid
  end

  it 'is not valid unless all of the associated libraries are valid' do
    dodgy_library = build(:pacbio_library, volume: nil)

    expect(build(:pacbio_pool, libraries: libraries + [dodgy_library])).to_not be_valid
  end

  context 'tags' do
    it 'will be valid if there is a single library with no tag' do
      expect(build(:pacbio_pool, libraries: [build(:pacbio_library, tag: nil)])).to be_valid
    end

    it 'will not be valid if there are multiple libraries and any of them dont have tags' do
      untagged_library = build(:pacbio_library, tag: nil)

      expect(build(:pacbio_pool, libraries: libraries + [untagged_library])).to_not be_valid
    end

    it 'is not valid unless all of the tags are unique' do
      library_with_duplicate_tag = build(:pacbio_library, tag: libraries.first.tag)
      expect(build(:pacbio_pool, libraries: libraries + [library_with_duplicate_tag])).to_not be_valid
    end

  end

 
  
end