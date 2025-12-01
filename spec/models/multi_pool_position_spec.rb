# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MultiPoolPosition do
  it 'is valid with with all required relationships and attributes' do
    expect(build(:multi_pool_position)).to be_valid
  end

  it 'is invalid without a pool' do
    expect(build(:multi_pool_position, pool: nil)).not_to be_valid
  end

  it 'is invalid without a multi_pool' do
    expect(build(:multi_pool_position, multi_pool: nil)).not_to be_valid
  end

  it 'is invalid without a position' do
    expect(build(:multi_pool_position, position: nil)).not_to be_valid
  end

  it 'is invalid if a multi_pool_position with the same pool already exists' do
    pool = create(:pacbio_pool)

    create(:multi_pool_position, pool: pool, position: 'A1')
    duplicate_position = build(:multi_pool_position, pool: pool, position: 'B2')

    expect(duplicate_position).not_to be_valid
    expect(duplicate_position.errors[:pool_id]).to include('has already been taken')
  end
end
