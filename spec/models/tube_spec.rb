require "rails_helper"

RSpec.describe Tube, type: :model do
  context 'on creation' do
    it 'should have a barcode' do
      sample = create(:sample)
      tube = create(:tube, material: sample)
      expect(tube.barcode).to eq "TRAC-#{tube.id}"
    end
  end

  context 'polymorphic behavior' do
    context 'schema' do
      it { is_expected.to have_db_column(:material_id).of_type(:integer) }
      it { is_expected.to have_db_column(:material_type).of_type(:string) }
    end

    context 'material' do
      it { is_expected.to belong_to(:material) }

      it 'must have material of either type sample or library' do
        expect(build(:tube, material: nil)).not_to be_valid
      end

      it 'can have a sample as its material' do
        sample = create(:sample)
        tube_with_sample = create(:tube, material: sample)
        expect(tube_with_sample).to be_valid
        expect(tube_with_sample.material).to eq sample
      end

      it 'can have a library as its material' do
        library = create(:library)
        tube_with_library = create(:tube, material: library)
        expect(tube_with_library).to be_valid
        expect(tube_with_library.material).to eq library
      end
    end
  end

  describe 'scope - by barcode' do

    let(:sample_tubes) { create_list(:tube, 5)}
    let(:library_tubes) { create_list(:tube_with_library, 5)}

    it 'will return the correct tubes' do
      expect(Tube.by_barcode(sample_tubes.first.barcode).length).to eq(1)
      expect(Tube.by_barcode(sample_tubes.pluck(:barcode)).length).to eq(5)
      expect(Tube.by_barcode(sample_tubes.pluck(:barcode).concat(library_tubes.pluck(:barcode))).length).to eq(10)
    end

    it ('will return nothing if barcode is dodgy') do
      expect(Tube.by_barcode('DODGY-BARCODE')).to be_empty
    end
  end
end
