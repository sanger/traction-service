# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SampleSheetBehaviour::Default do
  let(:tagged) { described_class.new }

  describe '#barcode_name' do
    it 'returns a formatted string with the tag_id' do
      tag = create(:tag, group_id: 'example')
      expect(tagged.barcode_name(tag)).to eq('example--example')
    end
  end

  describe '#barcode_set' do
    it 'returns the tag_set uuid' do
      tag_set = create(:tag_set)
      expect(tagged.barcode_set(tag_set)).to eq(tag_set.uuid)
    end
  end

  describe '#barcoded_for_sample_sheet?' do
    it 'returns true' do
      expect(tagged.barcoded_for_sample_sheet?).to be(true)
    end
  end

  describe '#aliquot_sample_name' do
    it 'returns the source sample name for a aliquot from a library' do
      library = create(:pacbio_library)
      aliquot = create(:aliquot, source: library)
      expect(tagged.aliquot_sample_name(aliquot)).to eq(library.sample_name)
    end

    it 'returns the source sample name for a aliquot from a request' do
      request = create(:pacbio_request)
      aliquot = create(:aliquot, source: request)
      expect(tagged.aliquot_sample_name(aliquot)).to eq(request.sample_name)
    end
  end

  describe '#show_row_per_sample?' do
    it 'returns true if any of the aliquots have a tag' do
      aliquots = create_list(:aliquot, 3)
      aliquots.first.tag = create(:tag)
      expect(tagged.show_row_per_sample?(aliquots)).to be(true)
    end

    it 'returns false if none of the aliquots have a tag' do
      aliquots = create_list(:aliquot, 3, tag: nil)
      expect(tagged.show_row_per_sample?(aliquots)).to be(false)
    end

    it 'returns false if there are no aliquots' do
      expect(tagged.show_row_per_sample?([])).to be(false)
    end
  end
end
