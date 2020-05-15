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
    new_flowcell = build(:ont_flowcell, position: flowcell.position, run:flowcell.run)
    expect(new_flowcell).to_not be_valid
  end
end
