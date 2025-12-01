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
end
