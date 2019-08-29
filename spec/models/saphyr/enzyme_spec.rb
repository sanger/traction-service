require "rails_helper"

RSpec.describe Saphyr::Enzyme, type: :model, saphyr: true do
  context 'on creation' do
    it 'should have a name' do
      expect(create(:saphyr_enzyme).name).to be_present
    end
  end

  describe 'name' do
    it 'must have a unique name' do
      enzyme = create(:saphyr_enzyme)
      expect(build(:saphyr_enzyme, name: enzyme.name)).not_to be_valid
    end

    it 'is not valid without a name' do
      expect(build(:saphyr_enzyme, name: nil)).not_to be_valid
    end
  end

  describe 'libraries' do
    it 'can have many librarues' do
      enzyme = create(:saphyr_enzyme)
      library1 = create(:saphyr_library, enzyme: enzyme)
      library2 = create(:saphyr_library, enzyme: enzyme)
      expect(enzyme.libraries).to eq [library1, library2]
    end
  end

end
