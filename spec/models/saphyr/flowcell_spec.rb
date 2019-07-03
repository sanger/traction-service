require "rails_helper"

RSpec.describe Saphyr::Flowcell, type: :model, saphyr: true do

  context 'on creation' do
    it 'must have a chip' do
      chip = create(:saphyr_chip)
      expect(create(:saphyr_flowcell, chip: chip)).to be_valid
      expect(build(:saphyr_flowcell, chip: nil)).not_to be_valid
    end

    it 'must have a position' do
      expect(create(:saphyr_flowcell, position: 1)).to be_valid
      expect(build(:saphyr_flowcell, position: nil)).not_to be_valid
    end

  end

  context 'chip' do
    it 'can have a chip' do
      chip = create(:saphyr_chip)
      expect(create(:saphyr_flowcell, chip: chip).chip).to eq chip
    end
  end

  context 'library' do
    it 'can have a library' do
      library = create(:saphyr_library)
      flowcell = create(:saphyr_flowcell, library: library)
      expect(flowcell.library).to eq library
    end

    it 'can be updated with a library' do
      flowcell = create(:saphyr_flowcell)
      library = create(:saphyr_library)
      flowcell.update(library: library)
      expect(flowcell.library).to eq library
    end

  end
end
