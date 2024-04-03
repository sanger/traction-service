# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SampleSheetBehaviour::Untagged do
  let(:untagged) { described_class.new }
  let(:tag) { create(:tag, group_id: 'example') }

  describe '#barcode_name' do
    it 'returns nil' do
      expect(untagged.barcode_name(tag)).to be_nil
    end
  end

  describe '#barcode_set' do
    it 'returns nil' do
      expect(untagged.barcode_set(tag)).to be_nil
    end
  end

  describe '#barcoded_for_sample_sheet?' do
    it 'returns false' do
      expect(untagged.barcoded_for_sample_sheet?).to be(false)
    end
  end

  describe '#aliquot_sample_name' do
    it 'returns the source sample name for a aliquot from a library' do
      library = create(:pacbio_library)
      aliquot = create(:aliquot, source: library)
      expect(untagged.aliquot_sample_name(aliquot)).to eq(library.sample_name)
    end

    it 'returns the source sample name for a aliquot from a request' do
      request = create(:pacbio_request)
      aliquot = create(:aliquot, source: request)
      expect(untagged.aliquot_sample_name(aliquot)).to eq(request.sample_name)
    end
  end

  describe '#show_row_per_sample?' do
    it 'returns nil' do
      aliquots = create_list(:aliquot, 3)
      expect(untagged.show_row_per_sample?(aliquots)).to be(false)
    end
  end
end
