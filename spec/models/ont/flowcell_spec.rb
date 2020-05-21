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
      expect(Ont::Flowcell.includes_args).to eq([
        library: Ont::Library.includes_args(:flowcell),
        run: Ont::Run.includes_args(:flowcells)
      ])
    end

    it 'removes run from includes_args' do
      expect(Ont::Flowcell.includes_args(:run)).to eq([library: Ont::Library.includes_args(:flowcell)])
    end

    it 'removes library from includes_args' do
      expect(Ont::Flowcell.includes_args(:library)).to eq([run: Ont::Run.includes_args(:flowcells)])
    end
  end
end
