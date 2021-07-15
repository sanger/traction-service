# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SampleSheet do
  context 'sample sheet methods' do
    let(:well) { create(:pacbio_well_with_pools, pool_count: 5) }
    let(:empty_well) { create(:pacbio_well) }

    context 'barcode_name' do
      it 'returns a string of library tags when the well has one library' do
        pool = create(:pacbio_pool, libraries: create_list(:pacbio_library, 1, :tagged ))
        empty_well.pools << pool
        tag_group_id = empty_well.pools.first.libraries.first.tag.group_id
        expected = "#{tag_group_id}--#{tag_group_id}"
        expect(empty_well.libraries.last.barcode_name).to eq expected
      end

      it 'returns nothing if the libraries are not tagged' do
        pool = create(:pacbio_pool, libraries: create_list(:pacbio_library, 1, :untagged ))
        empty_well.pools << pool
        expect(empty_well.libraries.last.barcode_name).to be_nil
      end
    end

    context 'barcode_set' do
      it 'returns the tag set uuid' do
        expected_set_name = well.libraries.first.tag.tag_set.uuid
        expect(well.barcode_set).to eq expected_set_name
      end

      it 'returns nothing if the libraries are not tagged' do
        pool = create(:pacbio_pool, libraries: create_list(:pacbio_library, 1, :untagged ))
        empty_well.pools << pool
        expect(empty_well.barcode_set).to be_nil
      end
    end

    context 'all_libraries_tagged' do
      it 'returns true if all well libraries are tagged' do
        expect(well.all_libraries_tagged).to eq true
      end

      it 'returns false if there is one library and it has no tag' do
        pool = create(:pacbio_pool, libraries: create_list(:pacbio_library, 1, :untagged ))
        empty_well.pools << pool
        expect(empty_well.all_libraries_tagged).to eq false
      end

      it 'returns true if there is only one library and it has a tag' do
        pool = create(:pacbio_pool)
        empty_well.pools << pool
        expect(empty_well.all_libraries_tagged).to eq true
      end

      it 'returns false if any of the well libraries are not tagged' do
        well.pools.first.libraries << create(:pacbio_library_without_tag)
        expect(well.all_libraries_tagged).to eq false
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
