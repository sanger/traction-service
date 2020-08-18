# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SampleSheet do
  context 'sample sheet methods' do
    let(:well_with_request_libraries) { create(:pacbio_well_with_request_libraries) }
    let(:well) { create(:pacbio_well) }

    context 'barcode_name' do
      it 'returns a string of library tags when the well has one library' do
        request_library = create(:pacbio_request_library_with_tag)
        well.libraries << request_library.library
        tag_group_id = request_library.tag.group_id
        expected = "#{tag_group_id}--#{tag_group_id}"
        expect(request_library.barcode_name).to eq expected
      end

      it 'returns nothing if the libraries are not tagged' do
        request_library = create(:pacbio_request_library)
        well.libraries << request_library.library
        expect(request_library.barcode_name).to be_nil
      end
    end

    context 'barcode_set' do
      it 'returns the tag set uuid' do
        request_library = create(:pacbio_request_library_with_tag)
        well.libraries << request_library.library
        expected_set_name = request_library.tag.tag_set.uuid
        expect(well.barcode_set).to eq expected_set_name
      end

      it 'returns nothing if the libraries are not tagged' do
        request_library = create(:pacbio_request_library)
        well.libraries << request_library.library
        expect(well.barcode_set).to be_nil
      end
    end

    context 'all_libraries_tagged' do
      it 'returns false if there is one library with no tag' do
        request_library = create(:pacbio_request_library)
        well.libraries << request_library.library
        expect(well.all_libraries_tagged).to eq false
      end

      it 'returns true if there is one library with a tag' do
        request_library = create(:pacbio_request_library_with_tag)
        well.libraries << request_library.library
        expect(well.all_libraries_tagged).to eq true
      end

      it 'returns true if all well libraries are tagged' do
        expect(well_with_request_libraries.all_libraries_tagged).to eq true
      end

      it 'returns false if any of the well libraries are not tagged' do
        request_library = create(:pacbio_request_library)
        well_with_request_libraries.libraries << request_library.library
        expect(well_with_request_libraries.all_libraries_tagged).to eq false
      end
    end

    context 'same_barcodes_on_both_ends_of_sequence' do
      it 'returns true' do
        expect(well.same_barcodes_on_both_ends_of_sequence).to eq true
      end
    end

    context 'position_leading_zero' do
      it 'can have a position with a leading zero for sample sheet generation' do
        expect(build(:pacbio_well, row: 'B', column: '1').position_leading_zero).to eq('B01')
      end
    end

    context 'with pre-extension time' do
      let(:well) { create(:pacbio_well, pre_extension_time: 3) }

      it 'automation parameters is formatted properly' do
        expect(well.automation_parameters).to eq("ExtensionTime=double:3|ExtendFirst=boolean:True")
      end
    end

    context 'without pre-extension time' do
      it 'automation parameters is blank' do
        expect(well.automation_parameters).to be_nil
      end
    end

    context 'pre-extension time 0' do
      let(:well) { create(:pacbio_well, pre_extension_time: 0) }

      it 'automation parameters is blank' do
        expect(well.automation_parameters).to be_nil
      end
    end
  end
end