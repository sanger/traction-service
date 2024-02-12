# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tube do
  it_behaves_like 'container'

  context 'labware' do
    let(:labware_model) { :tube_with_pacbio_request }

    it_behaves_like 'labware'
  end

  context 'on creation' do
    it 'has a barcode' do
      tube = create(:tube_with_pacbio_request)
      expect(tube.barcode).to eq "TRAC-2-#{tube.id}"
    end
  end

  describe 'scope - by barcode' do
    let(:pacbio_request_tubes) { create_list(:tube_with_pacbio_request, 5) }
    let(:pacbio_library_tubes) { create_list(:tube_with_pacbio_library, 5) }

    it 'returns the correct tubes' do
      expect(described_class.by_barcode(pacbio_request_tubes.first.barcode).length).to eq(1)
      expect(described_class.by_barcode(pacbio_request_tubes.pluck(:barcode)).length).to eq(5)
      expect(described_class.by_barcode(pacbio_request_tubes.pluck(:barcode).concat(pacbio_library_tubes.pluck(:barcode))).length).to eq(10)
    end

    it('returns nothing if barcode is dodgy') do
      expect(described_class.by_barcode('DODGY-BARCODE')).to be_empty
    end
  end

  context 'scope' do
    context 'by_pipeline pacbio' do
      it 'returns only tubes with pacbio materials' do
        create_list(:tube_with_pacbio_request, 2)
        expect(described_class.by_pipeline(:pacbio).length).to eq 2
      end

      it 'returns only tubes with ont materials' do
        create_list(:tube_with_ont_request, 3)
        expect(described_class.by_pipeline(:ont).length).to eq 3
      end
    end
  end
end
