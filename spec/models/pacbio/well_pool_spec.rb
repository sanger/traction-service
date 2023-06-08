# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::WellPool, pacbio: true do
  before do
    # Create a default pacbio smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v11', default: true)
  end

  it 'must have a well' do
    expect(build(:pacbio_well_pool, well: nil)).not_to be_valid
  end

  it 'must have a pool' do
    expect(build(:pacbio_well_pool, pool: nil)).not_to be_valid
  end
end
