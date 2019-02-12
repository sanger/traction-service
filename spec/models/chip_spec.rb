require "rails_helper"

RSpec.describe Chip, type: :model do

  context 'on creation' do
    it 'must have a barcode' do
      expect(create(:chip, barcode: "TRAC-123")).to be_valid
      expect(build(:chip, barcode: nil)).not_to be_valid
    end
  end

  context 'run' do
    it 'can belong to a run' do
      run = create(:run)
      expect(create(:chip, run: run)).to be_valid
    end

    it 'doesnt have to belong to a run' do
      expect(build(:chip, run: nil)).to be_valid
    end

    it 'can have a run' do
      run = create(:run)
      expect(create(:chip, run: run).run).to eq run
    end
  end

  context 'flowcells' do
    it 'can have many flowcells' do
      chip = create(:chip)
      flowcell1 = create(:flowcell, chip: chip, position: 1)
      flowcell2 = create(:flowcell, chip: chip, position: 2)
      expect(chip.flowcells).to eq([flowcell1, flowcell2])
    end

  end
end
