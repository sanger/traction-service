# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# only load Rake tasks if they haven't been loaded already
Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'RakeTasks' do
  subject(:task) { Rake::Task['single_use:merge_pacbio_smrtbell_tag_sets'] }

  describe 'single_use:merge_pacbio_smrtbell_tag_sets' do
    before do
      task.reenable
      Rake::Task['tags:create:SMRTbell_Barcoded_Adapter_Plates_ABCD'].reenable
      Rake::Task['tags:create:pacbio_96_barcode_plate_v3'].reenable
      Rake::Task['tags:create:SMRTbell_Barcoded_Adapter_Plates_ABCD'].invoke
      Rake::Task['tags:create:pacbio_96_barcode_plate_v3'].invoke
    end

    let!(:p96v3_tag_set) { TagSet.find_by(name: 'Pacbio_96_barcode_plate_v3') }
    let!(:smrtbell_tag_set) { TagSet.find_by(name: 'SMRTbell_Barcoded_Adapter_Plates_ABCD') }

    context 'when succesfully updating tags and tagsets' do
      let!(:p96_tag_1) { p96v3_tag_set.tags.find_by(group_id: 'bc2001') }
      let!(:p96_tag_2) { p96v3_tag_set.tags.find_by(group_id: 'bc2002') }
      let!(:smrt_tag_1) { smrtbell_tag_set.tags.find_by(group_id: 'bc2001') }
      let!(:smrt_tag_2) { smrtbell_tag_set.tags.find_by(group_id: 'bc2002') }

      let!(:library_using_old_smrt_tag) { create(:pacbio_library, tag: smrt_tag_1) }
      let!(:lbrary_pool_used_aliquot_using_old_smrt_tag) do
        create(:aliquot, source: library_using_old_smrt_tag,
                         used_by: create(:pacbio_pool), aliquot_type: :derived, tag: smrt_tag_1)
      end
      let!(:request_pool_used_aliquot_using_old_smrt_tag) do
        create(
          :aliquot,
          source: create(:pacbio_request),
          used_by: create(:pacbio_pool),
          aliquot_type: :derived,
          tag: smrt_tag_2
        )
      end
      let!(:unaffected_library) do
        create(:pacbio_library, tag: p96v3_tag_set.tags.find_by(group_id: 'bc2003'))
      end
      let!(:unaffected_aliquot) do
        create(
          :aliquot,
          source: create(:pacbio_request),
          used_by: create(:pacbio_pool),
          aliquot_type: :derived,
          tag: p96v3_tag_set.tags.find_by(group_id: 'bc2003')
        )
      end

      before do
        task.invoke
      end

      it 'outputs a success message' do
        task.reenable
        expect do
          task.invoke
        end.to output(/Successfully merged Pacbio_96_barcode_plate_v3 tag set/).to_stdout
      end

      it 'swaps tags between the two tag set' do
        expect(p96_tag_1.reload.tag_set).to eq(smrtbell_tag_set)
        expect(p96_tag_2.reload.tag_set).to eq(smrtbell_tag_set)
        expect(smrt_tag_1.reload.tag_set).to eq(p96v3_tag_set)
        expect(smrt_tag_2.reload.tag_set).to eq(p96v3_tag_set)
      end

      it 'migrates affected libraries and aliquots' do
        expect(library_using_old_smrt_tag.reload.tag).to eq(p96_tag_1)
        expect(library_using_old_smrt_tag.primary_aliquot.reload.tag).to eq(p96_tag_1)
        expect(library_using_old_smrt_tag.used_aliquots.first.reload.tag).to eq(p96_tag_1)
        expect(lbrary_pool_used_aliquot_using_old_smrt_tag.reload.tag).to eq(p96_tag_1)
        expect(request_pool_used_aliquot_using_old_smrt_tag.reload.tag).to eq(p96_tag_2)
        expect(unaffected_library.reload.tag).to eq(unaffected_library.tag)
        expect(unaffected_aliquot.reload.tag).to eq(unaffected_aliquot.tag)
      end

      it 'manages the tag_set updates' do
        # Ensure that the old Pacbio_96_barcode_plate_v3 tag set is deactivated
        expect(p96v3_tag_set.reload).not_to be_active
        # Ensure that the temporary tag set has been removed
        expect(TagSet.where('name LIKE ?', 'Pacbio_SMRTbell_merge_temp_%')).to be_empty
      end
    end

    context 'when one or both tag sets are missing' do
      it 'raises an error before making changes' do
        allow(TagSet).to receive(:find_by).and_call_original
        allow(TagSet).to receive(:find_by).with(name: 'Pacbio_96_barcode_plate_v3').and_return(nil)
        expect { task.invoke }.to raise_error(RuntimeError, /One or both tag sets not found/)
      end
    end

    context 'when the rollback is triggered it should not make any changes' do
      let!(:p96_tag_1) { p96v3_tag_set.tags.find_by(group_id: 'bc2001') }
      let!(:p96_tag_2) { p96v3_tag_set.tags.find_by(group_id: 'bc2002') }
      let!(:smrt_tag_1) { smrtbell_tag_set.tags.find_by(group_id: 'bc2001') }
      let!(:smrt_tag_2) { smrtbell_tag_set.tags.find_by(group_id: 'bc2002') }
      let(:task_context) { task.actions.first.binding.receiver }

      before do
        # Simulate a rollback by raising an error during the migration of libraries
        allow(task_context).to receive(:migrate_libraries).and_raise(ActiveRecord::Rollback)
      end

      it 'does not change any tags or tag sets' do
        expect(task_context).to receive(:migrate_libraries)
        expect { task.invoke }.not_to raise_error
        expect(p96_tag_1.reload.tag_set).to eq(p96v3_tag_set)
        expect(p96_tag_2.reload.tag_set).to eq(p96v3_tag_set)
        expect(smrt_tag_1.reload.tag_set).to eq(smrtbell_tag_set)
        expect(smrt_tag_2.reload.tag_set).to eq(smrtbell_tag_set)
      end
    end
  end
end
