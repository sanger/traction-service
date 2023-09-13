# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Saphyr::Enzyme, :saphyr do
  context 'on creation' do
    it 'has a name' do
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
      library1 = create(:saphyr_library, enzyme:)
      library2 = create(:saphyr_library, enzyme:)
      expect(enzyme.libraries).to eq [library1, library2]
    end
  end
end
