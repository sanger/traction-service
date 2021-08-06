require 'rails_helper'

RSpec.describe Pacbio::Pool, type: :model, pacbio: true do

  let(:libraries) { create_list(:pacbio_library, 5) }

  it 'will have a tube on validation' do
    pool = build(:pacbio_pool)
    pool.valid?
    expect(pool.tube).to be_a(Tube)
  end

  it 'can have many libraries' do
    pool = build(:pacbio_pool, libraries: libraries)
    expect(pool.libraries).to eq(libraries)
  end

  it 'can have a template prep kit box barcode' do
    pool = build(:pacbio_pool)
    expect(pool.template_prep_kit_box_barcode).to be_present
  end

  it 'can have a volume' do
    pool = build(:pacbio_pool)
    expect(pool.volume).to be_present
  end

  it 'can have a concentration' do
    pool = build(:pacbio_pool)
    expect(pool.concentration).to be_present
  end

  it 'can have a fragment size' do
    pool = build(:pacbio_pool)
    expect(pool.fragment_size).to be_present
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

  context 'wells' do
    it 'can have one or more' do
      pool = create(:pacbio_pool)
      pool.wells << create_list(:pacbio_well, 5)
      expect(pool.wells.count).to eq(5)
    end
  end

end
