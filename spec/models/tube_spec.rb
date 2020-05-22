require "rails_helper"

RSpec.describe Tube, type: :model do
  it_behaves_like 'container'

  context 'labware' do
    let(:labware_model) { :tube_with_saphyr_request }
    it_behaves_like 'labware'
  end

  context 'on creation' do
    it 'should have a barcode' do
      tube = create(:tube_with_saphyr_request)
      expect(tube.barcode).to eq "TRAC-2-#{tube.id}"
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

  context 'resolved' do
    it 'returns expected includes_args' do
      expect(Tube.includes_args.flat_map(&:keys)).to contain_exactly(:container_materials)
    end

    it 'removes container_materials from includes_args' do
      expect(Tube.includes_args(:container_materials).flat_map(&:keys))
        .to_not include(:container_materials)
    end
  end
end
