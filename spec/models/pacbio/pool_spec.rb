# frozen_string_literal: true

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

  it 'can have a insert size' do
    pool = build(:pacbio_pool)
    expect(pool.insert_size).to be_present
  end

  it 'is not valid unless there is at least one library' do
    expect(build(:pacbio_pool, libraries: [])).not_to be_valid
  end

  it 'is not valid unless all of the associated libraries are valid' do
    dodgy_library = build(:pacbio_library, volume: 'big')

    expect(build(:pacbio_pool, libraries: libraries + [dodgy_library])).not_to be_valid
  end

  describe '#library_attributes=' do
    context 'with new libraries' do
      let(:library_attributes) { attributes_for_list(:pacbio_library, 5) }

      it 'sets up libraries' do
        pool = build(:pacbio_pool, library_count: 0)
        pool.library_attributes = library_attributes
        expect(pool.libraries.length).to eq 5
      end
    end

    context 'with existing libraries' do
      let(:pool) { create(:pacbio_pool, library_count: 5) }
      let(:library_attributes) do
        pool.libraries.map do |library|
          library.attributes.merge(
            'template_prep_kit_box_barcode' => 'Updated'
          )
        end
      end

      it 'update existing libraries' do
        pool.library_attributes = library_attributes
        expect(pool.libraries.length).to eq 5
      end

      it 'changes library attributes' do
        pool.library_attributes = library_attributes
        expect(
          pool.libraries.map(&:template_prep_kit_box_barcode)
        ).to all eq 'Updated'
      end
    end
  end

  context 'tags' do
    it 'will be valid if there is a single library with no tag' do
      expect(build(:pacbio_pool, libraries: [build(:pacbio_library, tag: nil)])).to be_valid
    end

    it 'will not be valid if there are multiple libraries and any of them dont have tags' do
      untagged_library = build(:pacbio_library, tag: nil)

      expect(build(:pacbio_pool, libraries: libraries + [untagged_library])).not_to be_valid
    end

    it 'is not valid unless all of the tags are unique' do
      library_with_duplicate_tag = build(:pacbio_library, tag: libraries.first.tag)
      expect(build(:pacbio_pool,
                   libraries: libraries + [library_with_duplicate_tag])).not_to be_valid
    end
  end

  context 'wells' do
    it 'can have one or more' do
      pool = create(:pacbio_pool)
      pool.wells << create_list(:pacbio_well, 5)
      expect(pool.wells.count).to eq(5)
    end
  end

  describe '#sequencing_plates' do
    it 'when there is no run' do
      pool = create(:pacbio_pool)
      expect(pool.sequencing_plates).to be_empty
    end

    it 'when there is a single run' do
      plate = create(:pacbio_plate_with_wells, :pooled)
      pool = plate.wells.first.pools.first
      expect(pool.sequencing_plates).to eq([plate])
    end

    it 'when there are multiple runs' do
      plate1 = create(:pacbio_plate)
      plate2 = create(:pacbio_plate)
      pool = create(:pacbio_pool)
      create(:pacbio_well, pools: [pool], plate: plate1)
      create(:pacbio_well, pools: [pool], plate: plate2)
      expect(pool.sequencing_plates).to eq([plate1, plate2])
    end
  end
end
