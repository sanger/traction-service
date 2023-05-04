# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tube do
  it_behaves_like 'container'

  context 'labware' do
    let(:labware_model) { :tube_with_saphyr_request }

    it_behaves_like 'labware'
  end

  context 'on creation' do
    it 'has a barcode' do
      tube = create(:tube_with_saphyr_request)
      expect(tube.barcode).to eq "TRAC-2-#{tube.id}"
    end
  end

  describe 'scope - by barcode' do
    let(:saphyr_request_tubes) { create_list(:tube_with_saphyr_request, 5) }
    let(:saphyr_library_tubes) { create_list(:tube_with_saphyr_library, 5) }

    it 'will return the correct tubes' do
      expect(described_class.by_barcode(saphyr_request_tubes.first.barcode).length).to eq(1)
      expect(described_class.by_barcode(saphyr_request_tubes.pluck(:barcode)).length).to eq(5)
      expect(described_class.by_barcode(saphyr_request_tubes.pluck(:barcode).concat(saphyr_library_tubes.pluck(:barcode))).length).to eq(10)
    end

    it('will return nothing if barcode is dodgy') do
      expect(described_class.by_barcode('DODGY-BARCODE')).to be_empty
    end
  end

  context 'scope' do
    context 'by_pipeline saphyr' do
      it 'returns only tubes with saphyr materials' do
        create_list(:tube_with_saphyr_library, 2)
        expect(described_class.by_pipeline(:saphyr).length).to eq 2
      end

      it 'returns only tubes with pacbio materials' do
        create_list(:tube_with_pacbio_library, 3)
        expect(described_class.by_pipeline(:pacbio).length).to eq 3
      end
    end
  end
end
