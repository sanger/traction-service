require "rails_helper"

RSpec.describe Tube, type: :model do
  context 'on creation' do
    it 'should have a barcode' do
      tube = create(:tube_with_saphyr_request)
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

      it 'can have a request as its material' do
        request = create(:saphyr_request)
        tube_with_request = create(:tube, material: request)
        expect(tube_with_request).to be_valid
        expect(tube_with_request.material).to eq request
      end

      it 'can have a library as its material' do
        library = create(:saphyr_library)
        tube_with_library = create(:tube, material: library)
        expect(tube_with_library).to be_valid
        expect(tube_with_library.material).to eq library
      end
    end
  end

  describe 'scope - by barcode' do

    let(:saphyr_request_tubes) { create_list(:tube_with_saphyr_request, 5)}
    let(:saphyr_library_tubes) { create_list(:tube_with_saphyr_library, 5)}

    it 'will return the correct tubes' do
      expect(Tube.by_barcode(saphyr_request_tubes.first.barcode).length).to eq(1)
      expect(Tube.by_barcode(saphyr_request_tubes.pluck(:barcode)).length).to eq(5)
      expect(Tube.by_barcode(saphyr_request_tubes.pluck(:barcode).concat(saphyr_library_tubes.pluck(:barcode))).length).to eq(10)
    end

    it ('will return nothing if barcode is dodgy') do
      expect(Tube.by_barcode('DODGY-BARCODE')).to be_empty
    end
  end

  context 'scope' do
    let!(:saphyr_library_tubes) { create_list(:tube_with_saphyr_library, 2)}
    let!(:pacbio_library_tubes) { create_list(:tube_with_pacbio_library, 3)}

    context 'by_pipeline saphyr' do
      it 'should return only tubes with saphyr materials' do
        expect(Tube.by_pipeline(:saphyr).length).to eq 2
      end

      it 'should return only tubes with pacbio materials' do
        expect(Tube.by_pipeline(:pacbio).length).to eq 3
      end
    end

  end
end
