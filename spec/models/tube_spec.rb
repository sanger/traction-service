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
end
