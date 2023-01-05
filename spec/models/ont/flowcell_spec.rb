# frozen_string_literal: true

require 'rails_helper'
require './spec/support/read_only'

RSpec.describe Ont::Flowcell, ont: true do
  before do
    set_read_only([described_class, Ont::Run, Ont::Request, Ont::Library], false)
  end

  context 'uuidable' do
    let(:uuidable_model) { :ont_flowcell }

    it_behaves_like 'uuidable'

    it 'has a UUID field' do
      flowcell = create(:ont_flowcell)
      expect(flowcell.has_attribute?(:uuid)).to be true
      expect(flowcell.uuid).to be_present
    end
  end

  it 'must be valid when complete' do
    # Added this test to make sure other tests are not false positives
    flowcell = build(:ont_flowcell)
    expect(flowcell).to be_valid
  end

  it 'must have a position' do
    flowcell = build(:ont_flowcell, position: nil)
    expect(flowcell).not_to be_valid
  end

  it 'must have a run' do
    flowcell = build(:ont_flowcell, run: nil)
    expect(flowcell).not_to be_valid
  end

  it 'must have a pool' do
    flowcell = build(:ont_flowcell, pool: nil)
    expect(flowcell).not_to be_valid
  end

  it 'must have a unique position' do
    flowcell = create(:ont_flowcell)
    new_flowcell = build(:ont_flowcell, position: flowcell.position, run: flowcell.run)
    expect(new_flowcell).not_to be_valid
  end

  it 'returns pool requests' do
    flowcell = create(:ont_flowcell)
    expect(flowcell.requests).to eq(flowcell.pool.requests)
  end

  context 'on #destroy' do
    let(:flowcell) { create(:ont_flowcell) }

    it 'does not destroy the associated run' do
      run = flowcell.run
      initial_flowcell_count = run.flowcells.count
      flowcell.destroy
      expect(run).not_to be_destroyed
      expect(run.flowcells.count).to be(initial_flowcell_count - 1)
    end
  end
end
