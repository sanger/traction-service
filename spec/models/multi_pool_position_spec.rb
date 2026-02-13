# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MultiPoolPosition do
  it 'is valid with with all required relationships and attributes' do
    expect(build(:multi_pool_position)).to be_valid
  end

  it 'is invalid without a multi_pool' do
    expect(build(:multi_pool_position, multi_pool: nil)).not_to be_valid
  end

  it 'is invalid without a position' do
    expect(build(:multi_pool_position, position: nil)).not_to be_valid
  end

  it 'is invalid if a multi_pool_position with the same pool already exists' do
    pool = create(:pacbio_pool)

    create(:multi_pool_position, pool: pool, position: '1')
    duplicate_position = build(:multi_pool_position, pool: pool, position: '2')

    expect(duplicate_position).not_to be_valid
    expect(duplicate_position.errors[:pool_id]).to include('has already been taken')
  end

  it 'is invalid without either a pacbio_pool or ont_pool associated' do
    expect(build(:multi_pool_position, pacbio_pool: nil, ont_pool: nil)).not_to be_valid
  end

  describe '#pipeline' do
    it 'returns :pacbio when associated with a pacbio_pool' do
      multi_pool_position = create(:multi_pool_position, pacbio_pool: build(:pacbio_pool), ont_pool: nil)
      expect(multi_pool_position.pipeline).to eq(:pacbio)
    end

    it 'returns :ont when associated with an ont_pool' do
      multi_pool_position = create(:multi_pool_position, pacbio_pool: nil, ont_pool: build(:ont_pool))
      expect(multi_pool_position.pipeline).to eq(:ont)
    end

    it 'returns nil when not associated with any pool' do
      multi_pool_position = build(:multi_pool_position, pacbio_pool: nil, ont_pool: nil)
      expect(multi_pool_position.pipeline).to be_nil
    end
  end
end
