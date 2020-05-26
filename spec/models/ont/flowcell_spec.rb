# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ont::Flowcell, type: :model, ont: true do
  context 'uuidable' do
    let(:uuidable_model) { :ont_flowcell }
    it_behaves_like 'uuidable'
  end

  it 'must have a position' do
    flowcell = build(:ont_flowcell, position: nil)
    expect(flowcell).to_not be_valid
  end

  it 'must have a run' do
    flowcell = build(:ont_flowcell, run: nil)
    expect(flowcell).to_not be_valid
  end

  it 'must have a library' do
    flowcell = build(:ont_flowcell, library: nil)
    expect(flowcell).to_not be_valid
  end

  it 'must have a unique position' do
    flowcell = create(:ont_flowcell)
    new_flowcell = build(:ont_flowcell, position: flowcell.position, run: flowcell.run)
    expect(new_flowcell).to_not be_valid
  end

  it 'returns library requests' do
    flowcell = create(:ont_flowcell)
    expect(flowcell.requests).to eq(flowcell.library.requests)
  end

  context 'on #destroy' do
    let(:flowcell) { create(:ont_flowcell) }

    it 'does not destroy the associated run' do
      run = flowcell.run
      initial_flowcell_count = run.flowcells.count
      flowcell.destroy
      expect(run.destroyed?).to be_falsey
      expect(run.flowcells.count).to be(initial_flowcell_count - 1)
    end
  end

  context 'resolve' do
    it 'returns expected includes_args' do
      expect(Ont::Flowcell.includes_args.flat_map(&:keys)).to contain_exactly(:library, :run)
    end

    it 'removes run from includes_args' do
      expect(Ont::Flowcell.includes_args(:run).flat_map(&:keys)).to_not include(:run)
    end

    it 'removes library from includes_args' do
      expect(Ont::Flowcell.includes_args(:library).flat_map(&:keys)).to_not include(:library)
    end
  end
end
