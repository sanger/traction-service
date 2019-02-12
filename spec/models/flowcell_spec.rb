require "rails_helper"

RSpec.describe Flowcell, type: :model do

  context 'on creation' do
    it 'must have a chip' do
      chip = create(:chip)
      expect(create(:flowcell, chip: chip)).to be_valid
      expect(build(:flowcell, chip: nil)).not_to be_valid
    end

    it 'must have a position' do
      expect(create(:flowcell, position: 1)).to be_valid
      expect(build(:flowcell, position: nil)).not_to be_valid
    end

  end

  context 'chip' do
    it 'can have a chip' do
      chip = create(:chip)
      expect(create(:flowcell, chip: chip).chip).to eq chip
    end
  end

  context 'library' do
    it 'can have a library' do
      flowcell = create(:flowcell)
      library = create(:library, flowcell: flowcell)
      expect(flowcell.library).to eq library
    end
  end
end
