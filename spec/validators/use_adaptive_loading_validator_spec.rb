# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UseAdaptiveLoadingValidator do
  before do
    create(:pacbio_smrt_link_version, name: 'v13_1_revio', default: true)
  end

  let(:run) { create(:pacbio_revio_run) }
  let(:validator) { described_class.new(run:, exclude_marked_for_destruction: true) }

  it 'is valid when all wells have the same use_adaptive_loading value' do
    # Factory defaults to false for use_adaptive_loading for all wells
    well = run.wells.first
    validator.validate(well)
    expect(well.errors).to be_empty
  end

  it 'is invalid when all wells do not have the same use_adaptive_loading value' do
    well = run.wells.last
    well.use_adaptive_loading = true

    validator.validate(well)
    expect(well.errors[:base]).to include("well #{run.wells.last.position} has a differing 'Use Adaptive Loading' value")
  end
end
