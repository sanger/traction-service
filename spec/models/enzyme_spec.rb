require "rails_helper"

RSpec.describe Enzyme, type: :model do
  context 'on creation' do
    it 'should have a name' do
      expect(create(:enzyme, name: 'Nb.BbvCI').name).to eq('Nb.BbvCI')
    end
  end

  describe 'name' do
    it 'must have a unique name' do
      enzyme = create(:enzyme, name: 'Nb.BbvCI')
      expect(build(:enzyme, name: enzyme.name)).not_to be_valid
    end

    it 'is not valid without a name' do
      expect(build(:enzyme, name: nil)).not_to be_valid
    end
  end

  describe 'libraries' do
    it 'can have many librarues' do
      enzyme = create(:enzyme)
      library1= create(:library, enzyme: enzyme)
      library2= create(:library, enzyme: enzyme)
      expect(enzyme.libraries).to eq [library1, library2]
    end
  end

end
