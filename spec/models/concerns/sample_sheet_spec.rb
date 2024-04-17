# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SampleSheet do
  before do
    # Create a default pacbio smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v12_sequel_iie', default: true)
  end

  context 'with a pacbio well' do
    let(:well) { create(:pacbio_well, pool_count: 5) }

    describe '#barcode_set' do
      it 'returns the tag set uuid' do
        expected_set_name = well.base_used_aliquots.first.tag.tag_set.uuid
        expect(well.barcode_set).to eq expected_set_name
      end

      it 'returns nothing if the aliquots are not tagged' do
        pool = create(:pacbio_pool, :untagged, library_count: 1)
        empty_well = create(:pacbio_well, pools: [pool])
        expect(empty_well.barcode_set).to be_nil
      end

      it 'returns nothing if the aliquots are tagged with a :hidden tag set (egh. IsoSeq)' do
        pool = create(:pacbio_pool, :hidden_tagged, library_count: 1)
        empty_well = create(:pacbio_well, pools: [pool])
        expect(empty_well.barcode_set).to be_nil
      end
    end

    describe '#sample_is_barcoded' do
      it 'returns true if all well aliquots are tagged and non isoSeq tags' do
        expect(well.sample_is_barcoded).to be true
      end

      it 'returns false if there is one aliquots and it has no tag' do
        pool = create(:pacbio_pool, :untagged, library_count: 1)
        empty_well = create(:pacbio_well, pools: [pool])
        expect(empty_well.sample_is_barcoded).to be false
      end

      it 'returns true if there is only one aliquots and it has a non isoSeq tag' do
        pool = create(:pacbio_pool)
        empty_well = create(:pacbio_well, pools: [pool])
        expect(empty_well.sample_is_barcoded).to be true
      end

      it 'returns false if the aliquots are tagged with a :hidden tag set (egh. IsoSeq)' do
        pool = create(:pacbio_pool, :hidden_tagged, library_count: 1)
        empty_well = create(:pacbio_well, pools: [pool])
        expect(empty_well.sample_is_barcoded).to be false
      end
    end

    describe '#bio_sample_name' do
      context 'when tag set is :default type' do
        it 'returns nothing if row type is well' do
          expect(well.bio_sample_name).to be_nil
        end

        it 'returns aliquot sample_name when well has libraries and row type is library' do
          aliquot = create(:pacbio_library).used_aliquots.first
          expect(aliquot.bio_sample_name).to eq aliquot.source.sample_name
        end
      end

      context 'when tag set is :hidden type (eg. IsoSeq)' do
        let(:library) { create(:pacbio_library, :hidden_tagged) }

        it 'returns well sample_names if row type is well' do
          pool = create(:pacbio_pool, :hidden_tagged, library_count: 1)
          empty_well = create(:pacbio_well, pools: [pool])
          expect(empty_well.bio_sample_name).to eq empty_well.sample_names
        end

        it 'returns nothing when well has libraries and row type is library' do
          aliquot = library.used_aliquots.first
          expect(aliquot.bio_sample_name).to eq ''
        end
      end
    end

    context 'show_row_per_sample?' do
      it 'returns true if all well aliquots are tagged' do
        expect(well.show_row_per_sample?).to be true
      end

      it 'returns false if there is one library and it has no tag' do
        pool = create(:pacbio_pool, :untagged, library_count: 1)
        empty_well = create(:pacbio_well, pools: [pool])
        expect(empty_well.show_row_per_sample?).to be false
      end

      it 'returns true if there is only one library and it has a tag' do
        pool = create(:pacbio_pool)
        empty_well = create(:pacbio_well, pools: [pool])
        expect(empty_well.show_row_per_sample?).to be true
      end

      it 'returns true if at least one of the well aliquots are tagged' do
        well.pools.first.used_aliquots << create(:aliquot, tag: create(:tag), source: create(:pacbio_library))
        expect(well.show_row_per_sample?).to be true
      end

      it 'returns nothing if the aliquots are tagged with a :hidden tag set (egh. IsoSeq)' do
        pool = create(:pacbio_pool, :hidden_tagged, library_count: 3)
        empty_well = create(:pacbio_well, pools: [pool])
        expect(empty_well.show_row_per_sample?).to be false
      end
    end

    context 'tube_barcode' do
      it 'returns the first aliquots tube barcode in well' do
        expected = well.base_used_aliquots.first.used_by.tube.barcode
        expect(well.tube_barcode).to eq expected
      end
    end

    context 'same_barcodes_on_both_ends_of_sequence' do
      let(:well) { create(:pacbio_well, pools:) }

      context 'when the well contains tags' do
        let(:pools) { create_list(:pacbio_pool, 1, :tagged) }

        it 'returns true' do
          expect(well.same_barcodes_on_both_ends_of_sequence).to be true
        end
      end

      context 'when the well does not contain tags' do
        let(:pools) { create_list(:pacbio_pool, 1, :untagged) }

        it 'returns nil' do
          expect(well.same_barcodes_on_both_ends_of_sequence).to be_nil
        end
      end
    end

    context 'position_leading_zero' do
      it 'can have a position with a leading zero for sample sheet generation' do
        expect(build(:pacbio_well, row: 'B', column: '1').position_leading_zero).to eq('B01')
      end
    end

    context 'plate_well_position' do
      let(:plate) { build(:pacbio_plate, plate_number: 2) }
      let(:well) { create(:pacbio_well, plate:, row: 'B', column: '1') }

      it 'prefixes the well position with the plate number' do
        expect(well.plate_well_position).to eq('2_B01')
      end
    end

    context 'with pre-extension time' do
      let(:well) { create(:pacbio_well, pre_extension_time: 3) }

      it 'automation parameters is formatted properly' do
        expect(well.automation_parameters).to eq("ExtensionTime=double:#{well.pre_extension_time}|ExtendFirst=boolean:True")
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

  context 'with an aliquot' do
    describe '#barcode_name' do
      let(:library_count) { 1 }
      let(:empty_well) { create(:pacbio_well, pools: [pool]) }

      context 'when the well has one aliquot' do
        let(:pool) { create(:pacbio_pool, :tagged, library_count:) }

        it 'returns a string of aliquot tags' do
          tag_group_id = empty_well.base_used_aliquots.first.tag.group_id
          expected = "#{tag_group_id}--#{tag_group_id}"
          expect(empty_well.base_used_aliquots.last.barcode_name).to eq expected
        end
      end

      context 'when the aliquots are tagged with a :hidden tag set (egh. IsoSeq)' do
        let(:pool) { create(:pacbio_pool, :hidden_tagged, library_count:) }

        it 'returns nothing' do
          expect(empty_well.base_used_aliquots.last.barcode_name).to be_nil
        end
      end

      context 'when the aliquots are not tagged' do
        let(:pool) { create(:pacbio_pool, :untagged, library_count:) }

        it 'returns nothing' do
          expect(empty_well.base_used_aliquots.last.barcode_name).to be_nil
        end
      end
    end

    describe '#adapter' do
      context 'when the aliquot is tagged' do
        let(:well) { create(:pacbio_well, pool_count: 1) }

        it 'returns the tag group id' do
          aliquot = well.base_used_aliquots.first
          expect(aliquot.adapter).to eq aliquot.tag.group_id
        end
      end

      context 'when the aliquot is not tagged' do
        let(:pool) { create(:pacbio_pool, :untagged, library_count: 1) }
        let(:well) { create(:pacbio_well, pools: [pool]) }

        it 'returns nil' do
          aliquot = well.base_used_aliquots.first
          expect(aliquot.adapter).to be_nil
        end
      end
    end
  end
end
