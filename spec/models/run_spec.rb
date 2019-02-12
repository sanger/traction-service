require "rails_helper"

RSpec.describe Run, type: :model do

  context 'on creation' do
    it 'must exist' do
      expect(create(:run)).to be_valid
    end
  end

  context 'chip' do
    it 'can have a chip' do
      run = create(:run)
      chip = create(:chip, run: run)
      expect(run.chip).to eq chip
    end
  end

  context 'run relationships' do
    it 'can have a chip with two flowcells each with a library' do
      run = create(:run)
      chip = create(:chip, run: run)
      flowcell1 = create(:flowcell, chip: chip, position: 1)
      flowcell2 = create(:flowcell, chip: chip, position: 2)
      library1 = create(:library, flowcell: flowcell1)
      library2 = create(:library, flowcell: flowcell2)

      expect(run.chip).to eq chip
      expect(run.chip.flowcells).to eq [flowcell1, flowcell2]
      expect(run.chip.flowcells[0].library).to eq(library1)
      expect(run.chip.flowcells[1].library).to eq(library2)
    end
  end

end
