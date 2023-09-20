# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ont::Flowcell, :ont do
  before do
    # Create a MinKnow default version so that associated runs can be saved
    create(:ont_min_know_version_default, name: 'v22')
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

  it 'must have an integer position' do
    flowcell = build(:ont_flowcell, position: 'NOT_NUMBER')
    expect(flowcell).not_to be_valid
  end

  it 'must have a correct position range' do
    flowcell = build(:ont_flowcell)
    flowcell.position = flowcell.run.instrument.max_number_of_flowcells + 1
    expect(flowcell).not_to be_valid
  end

  it 'must have a run' do
    flowcell = build(:ont_flowcell, run: nil)
    expect(flowcell).not_to be_valid
  end

  it 'must have a flowcell_id' do
    flowcell = build(:ont_flowcell, flowcell_id: nil)
    expect(flowcell).not_to be_valid
  end

  it 'must have a pool' do
    flowcell = build(:ont_flowcell, pool: nil)

    expect(flowcell).not_to be_valid
    expect(flowcell.errors.full_messages).to include("Pool pool at position #{flowcell.position_name} is unknown")
  end

  it 'must have a correct ont_pool_id' do
    flowcell = build(:ont_flowcell)
    flowcell.ont_pool_id = -1

    expect(flowcell).not_to be_valid
    expect(flowcell.errors.full_messages).to include("Pool pool at position #{flowcell.position_name} is unknown")
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

  context 'flowcell adressing' do
    it 'returns coordinates for PromethION' do
      run = create(:ont_promethion_run, flowcell_count: 24)
      first = run.flowcells.find_by(position: 1)
      last = run.flowcells.find_by(position: 24)

      expect(first.position).to eq(1)
      expect(first.position_name).to eq('1A')

      expect(last.position).to eq(24)
      expect(last.position_name).to eq('3H')
    end

    it 'includes coordinates for PromethION errors' do
      run = create(:ont_promethion_run, flowcell_count: 2)
      flowcell_id = run.flowcells[0].flowcell_id = run.flowcells[1].flowcell_id
      display0 = run.flowcells[0].position_name
      display1 = run.flowcells[1].position_name

      expect(run).not_to be_valid

      expect(run.errors.full_messages).to include("Flowcells flowcell_id #{flowcell_id} at position #{display0} is duplicated in the same run")
      expect(run.errors.full_messages).to include("Flowcells flowcell_id #{flowcell_id} at position #{display1} is duplicated in the same run")
    end

    it 'returns x-positions for GridION' do
      run = create(:ont_gridion_run, flowcell_count: 5)
      first = run.flowcells.find_by(position: 1)
      last = run.flowcells.find_by(position: 5)

      expect(first.position).to eq(1)
      expect(first.position_name).to eq('x1')

      expect(last.position).to eq(5)
      expect(last.position_name).to eq('x5')
    end

    it 'returns number for MinION' do
      run = create(:ont_minion_run)
      first = run.flowcells.find_by(position: 1)
      last = run.flowcells.find_by(position: 1)

      expect(first.position).to eq(1)
      expect(first.position_name).to eq(1)

      expect(last.position).to eq(1)
      expect(last.position_name).to eq(1)
    end
  end
end
