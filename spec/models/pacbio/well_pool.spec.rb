require 'rails_helper'

RSpec.describe Pacbio::WellPool, type: :model, pacbio: true do

  it 'must have a well' do
    expect(build(:pacbio_well_pool, well: nil)).to_not be_valid
  end

  it 'must have a pool' do
    expect(build(:pacbio_well_pool, pool: nil)).to_not be_valid
  end
end
