# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MultiPool do
  it 'is valid with with all required relationships and attributes' do
    expect(build(:multi_pool)).to be_valid
  end

  it 'is invalid without a pipeline' do
    expect(build(:multi_pool, pipeline: nil)).not_to be_valid
  end

  it 'is invalid without a pool_method' do
    expect(build(:multi_pool, pool_method: nil)).not_to be_valid
  end

  it 'is invalid with a bad pool_method' do
    expect { build(:multi_pool, pool_method: 'InvalidMethod') }.to raise_error(ArgumentError).with_message(/is not a valid pool_method/)
  end

  it 'is invalid without multi_pool_positions' do
    multi_pool = build(:multi_pool)
    multi_pool.multi_pool_positions = []
    expect(multi_pool).not_to be_valid
    expect(multi_pool.errors[:multi_pool_positions]).to include("can't be blank")
  end

  it 'is invalid with varying pool types' do
    multi_pool = build(:multi_pool)
    multi_pool.multi_pool_positions << build(:multi_pool_position, pool: create(:ont_pool))
    multi_pool.multi_pool_positions << build(:multi_pool_position, pool: create(:pacbio_pool))

    expect(multi_pool).not_to be_valid
    expect(multi_pool.errors[:multi_pool_positions]).to include('all pools must be of the same type')
  end

  it 'is invalid with duplicate pool positions' do
    multi_pool = build(:multi_pool)
    multi_pool.multi_pool_positions << build(:multi_pool_position, position: 1)
    multi_pool.multi_pool_positions << build(:multi_pool_position, position: 1)

    expect(multi_pool).not_to be_valid
    expect(multi_pool.errors[:multi_pool_positions]).to include('1 positions are duplicated')
  end

  describe '#consistent_pools_type?' do
    it 'returns true if there are no pools' do
      multi_pool = build(:multi_pool, multi_pool_positions: [])

      expect(multi_pool.consistent_pools_type?).to be true
    end

    it 'returns true if all pools are the same type' do
      multi_pool = build(:multi_pool)
      multi_pool.multi_pool_positions = build_list(:multi_pool_position, 2, pool: create(:pacbio_pool))

      expect(multi_pool.consistent_pools_type?).to be true
    end

    it 'returns false and adds an error if there are varying pool types' do
      multi_pool = build(:multi_pool)
      multi_pool.multi_pool_positions << build(:multi_pool_position, pool: create(:ont_pool))
      multi_pool.multi_pool_positions << build(:multi_pool_position, pool: create(:pacbio_pool))

      expect(multi_pool.consistent_pools_type?).to be false
      expect(multi_pool.errors[:multi_pool_positions]).to include('all pools must be of the same type')
    end
  end

  describe '#unique_pool_positions?' do
    it 'returns true if there are no pools' do
      multi_pool = build(:multi_pool, multi_pool_positions: [])

      expect(multi_pool.unique_pool_positions?).to be true
    end

    it 'returns true if all pools are in a unique position' do
      multi_pool = build(:multi_pool)
      multi_pool.multi_pool_positions << build(:multi_pool_position, pool: create(:pacbio_pool), position: 1)
      multi_pool.multi_pool_positions << build(:multi_pool_position, pool: create(:pacbio_pool), position: 2)

      expect(multi_pool.unique_pool_positions?).to be true
    end

    it 'returns false and adds an error if some pools are in the same position' do
      multi_pool = build(:multi_pool)
      multi_pool.multi_pool_positions << build(:multi_pool_position, pool: create(:pacbio_pool), position: 1)
      multi_pool.multi_pool_positions << build(:multi_pool_position, pool: create(:pacbio_pool), position: 1)

      expect(multi_pool.unique_pool_positions?).to be false
      expect(multi_pool.errors[:multi_pool_positions]).to include('1 positions are duplicated')
    end
  end

  describe '#number_of_pools' do
    it 'returns the count of multi_pool_positions' do
      multi_pool = build(:multi_pool)
      multi_pool.multi_pool_positions = build_list(:multi_pool_position, 3, pool: create(:pacbio_pool))

      expect(multi_pool.number_of_pools).to eq 3
    end
  end

  describe '#sufficient_library_available_volume?' do
    it 'returns true if there are no pools' do
      multi_pool = build(:multi_pool, multi_pool_positions: [])

      expect(multi_pool.sufficient_library_available_volume?).to be true
    end

    it 'returns true if all sources have sufficient available volume' do
      library = create(:pacbio_library, volume: 100, tube: create(:tube, barcode: 'TRAC-2-1'))
      pool1 = create(:pacbio_pool, used_aliquots: [create(:aliquot, source: library, volume: 30)])
      pool2 = create(:pacbio_pool, used_aliquots: [create(:aliquot, source: library, volume: 20)])
      pool3 = create(:pacbio_pool, used_aliquots: [create(:aliquot, source: create(:pacbio_request), volume: 10)])
      multi_pool = build(:multi_pool, multi_pool_positions: [], pipeline: 'pacbio')
      multi_pool.multi_pool_positions << build(:multi_pool_position, pacbio_pool: pool1, position: 1)
      multi_pool.multi_pool_positions << build(:multi_pool_position, pacbio_pool: pool2, position: 2)
      multi_pool.multi_pool_positions << build(:multi_pool_position, pacbio_pool: pool3, position: 3)

      expect(multi_pool.sufficient_library_available_volume?).to be true
    end

    it 'returns false and adds an error if any source does not have sufficient available volume' do
      library = build(:pacbio_library, volume: 100, tube: create(:tube, barcode: 'TRAC-2-1'))
      pool1 = build(:pacbio_pool, used_aliquots: [build(:aliquot, source: library, volume: 60)])
      pool2 = build(:pacbio_pool, used_aliquots: [build(:aliquot, source: library, volume: 50)])
      multi_pool = build(:multi_pool, multi_pool_positions: [], pipeline: 'pacbio')
      multi_pool.multi_pool_positions << build(:multi_pool_position, pacbio_pool: pool1, position: 1)
      multi_pool.multi_pool_positions << build(:multi_pool_position, pacbio_pool: pool2, position: 2)

      expect(multi_pool.sufficient_library_available_volume?).to be false
      expect(multi_pool.errors[:base]).to include("#{library.barcode} does not have sufficient available volume")
    end
  end
end
