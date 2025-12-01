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
      multi_pool.multi_pool_positions << build(:multi_pool_position, pool: create(:pacbio_pool), position: 'B1')
      multi_pool.multi_pool_positions << build(:multi_pool_position, pool: create(:pacbio_pool), position: 'B2')

      expect(multi_pool.unique_pool_positions?).to be true
    end

    it 'returns false and adds an error if some pools are in the same position' do
      multi_pool = build(:multi_pool)
      multi_pool.multi_pool_positions << build(:multi_pool_position, pool: create(:pacbio_pool), position: 'B1')
      multi_pool.multi_pool_positions << build(:multi_pool_position, pool: create(:pacbio_pool), position: 'B1')

      expect(multi_pool.unique_pool_positions?).to be false
      expect(multi_pool.errors[:multi_pool_positions]).to include('B1 positions are duplicated')
    end
  end

  describe '#number_of_pools' do
    it 'returns the count of multi_pool_positions' do
      multi_pool = build(:multi_pool)
      multi_pool.multi_pool_positions = build_list(:multi_pool_position, 3, pool: create(:pacbio_pool))

      expect(multi_pool.number_of_pools).to eq 3
    end
  end
end
