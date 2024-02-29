# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::WellLibrary, :pacbio do
  before do
    # Create a default pacbio smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v12', default: true)
  end

  it 'must have a well' do
    expect(build(:pacbio_well_library, well: nil)).not_to be_valid
  end

  it 'must have a library' do
    expect(build(:pacbio_well_library, library: nil)).not_to be_valid
  end
end
