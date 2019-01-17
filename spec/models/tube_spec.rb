require "rails_helper"

RSpec.describe Tube, type: :model do
  context 'on creation' do
    it 'should have a barcode' do
      tube = create(:tube)
      expect(tube.barcode).to eq "TRAC-#{tube.id}"
    end

    it 'can have a library' do
      library = create(:library)
      expect(create(:tube, library: library).library).to be_present
    end
  end

  context 'polymorphic behavior' do
    it { is_expected.to have_db_column(:material_id).of_type(:integer) }
    it { is_expected.to have_db_column(:material_type).of_type(:string) }
    it { is_expected.to belong_to(:material) }
  end
end
