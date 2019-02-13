require "rails_helper"

RSpec.describe Chip, type: :model do

  context 'on create' do
    it 'has two flowcells' do
      chip = create(:chip)
      expect(chip.flowcells.length).to eq 2
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

  context 'barcode' do
    it 'can have a barcode' do
      expect(create(:chip, barcode: "TRAC-123")).to be_valid
      expect(create(:chip, barcode: nil)).to be_valid
    end

    it 'can be updated with a barcode' do
      chip = create(:chip)
      chip.update(barcode: "TRAC-123")
      expect(chip.barcode).to eq "TRAC-123"
    end
  end
end
