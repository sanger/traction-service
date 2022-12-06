# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::WellPool, pacbio: true do
  it 'must have a well' do
    expect(build(:pacbio_well_pool, well: nil)).not_to be_valid
  end

  it 'must have a pool' do
    expect(build(:pacbio_well_pool, pool: nil)).not_to be_valid
  end
end
