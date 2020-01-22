# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SampleSheet do
  context 'sample sheet methods' do
    let(:well_with_request_libraries) { create(:pacbio_well_with_request_libraries) }
    let(:well) { create(:pacbio_well) }

    # rename to whatever the tags are
    context 'barcode_name' do
      xit 'returns a string of library tags when the well has one library' do
      end

      xit 'returns a string of library tags when the well has many libraries' do
      end
    end

    # rename to whatever barcode set is
    context 'barcode_set' do
      xit 'returns a string of the library request tags group id when the well has one library' do
      end

      xit 'returns a string of the library request tags group ids when the well has many libraries' do
      end
    end

    context 'all_libraries_tagged' do
      xit 'returns true if all well libraries are tagged' do
      end

      xit 'returns false if any of the well libraries are not tagged' do
      end
    end

    context 'same_barcodes_on_both_ends_of_sequence' do
      it 'returns true' do
        expect(well.same_barcodes_on_both_ends_of_sequence).to eq true
      end
    end

    context 'bio_sample_name' do
      it 'returns the wells library request sample name when the well has one library' do
        request_library = create(:pacbio_request_library_with_tag).library
        well.libraries << request_library
        expected = well.libraries[0].request_libraries.first.request.sample.name
        expect(well.bio_sample_name).to eq expected
      end

      it 'returns the wells library requests sample names when the well has many libraries' do
        expected = well_with_request_libraries.request_libraries.collect(&:request).collect(&:sample_name).join(',')
        expect(well_with_request_libraries.bio_sample_name).to eq expected
      end
    end

    context 'position_leading_zero' do
      it 'can have a position with a leading zero for sample sheet generation' do
        expect(build(:pacbio_well, row: 'B', column: '1').position_leading_zero).to eq('B01')
      end
    end

  end
end