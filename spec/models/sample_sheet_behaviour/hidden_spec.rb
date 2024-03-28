# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SampleSheetBehaviour::Hidden do
  let(:hidden) { described_class.new }
  let(:tag) { create(:tag, group_id: 'example') }
  let(:aliquot) { create(:aliquot, source: create(:pacbio_request)) }

  describe '#barcode_name' do
    it 'returns nil' do
      expect(hidden.barcode_name(tag)).to be_nil
    end
  end

  describe '#barcode_set' do
    it 'returns nil' do
      expect(hidden.barcode_set(tag)).to be_nil
    end
  end

  describe '#barcoded_for_sample_sheet?' do
    it 'returns false' do
      expect(hidden.barcoded_for_sample_sheet?).to be(false)
    end
  end

  describe '#aliquot_sample_name' do
    it 'returns an empty string' do
      expect(hidden.aliquot_sample_name(aliquot)).to eq('')
    end
  end

  describe '#show_row_per_sample?' do
    it 'returns false' do
      expect(hidden.show_row_per_sample?([aliquot])).to be(false)
    end
  end
end
