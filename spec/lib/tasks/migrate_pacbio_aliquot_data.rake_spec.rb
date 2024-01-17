# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# only load Rake tasks if they haven't been loaded already
Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'RakeTasks' do
  before do
    Pacbio::SmrtLinkVersion.find_by(name: 'v12_sequel_iie') || create(:pacbio_smrt_link_version, name: 'v12_sequel_iie', default: true)
  end

  describe 'pacbio_aliquot_data:migrate_pool_data' do
    it 'creates primary and derived aliquots for each pool and well pool' do
      # Create some pools with wells
      wells = create_list(:pacbio_well, 5, pool_count: 2, aliquots: [])
      pools = wells.map(&:pools).flatten

      # Run the rake task
      # It outputs the correct text
      expect { Rake::Task['pacbio_aliquot_data:migrate_pool_data'].invoke }.to output(
        <<~HEREDOC
          -> Creating primary aliquots for all pools
        HEREDOC
      ).to_stdout

      # Check if the primary and derived aliquots have been created
      pools.each do |pool|
        expect(pool.primary_aliquot.volume).to eq(pool.volume)
        expect(pool.primary_aliquot.concentration).to eq(pool.concentration)
        expect(pool.primary_aliquot.template_prep_kit_box_barcode).to eq(pool.template_prep_kit_box_barcode)
        expect(pool.primary_aliquot.insert_size).to eq(pool.insert_size)

        expect(pool.derived_aliquots.count).to eq(pool.wells.count)
        pool.derived_aliquots.each do |derived_aliquot|
          expect(derived_aliquot.volume).to eq(pool.volume)
          expect(derived_aliquot.concentration).to eq(pool.concentration)
          expect(derived_aliquot.template_prep_kit_box_barcode).to eq(pool.template_prep_kit_box_barcode)
          expect(derived_aliquot.insert_size).to eq(pool.insert_size)
        end
      end

      wells.each do |well|
        # Each well should have 2 derived aliquots, one for each pool
        expect(well.aliquots.count).to eq(2)
        well.aliquots.each do |aliquot|
          expect(aliquot.aliquot_type).to eq('derived')
          expect(aliquot.volume).to eq(aliquot.source.volume)
          expect(aliquot.concentration).to eq(aliquot.source.concentration)
          expect(aliquot.template_prep_kit_box_barcode).to eq(aliquot.source.template_prep_kit_box_barcode)
          expect(aliquot.insert_size).to eq(aliquot.source.insert_size)
        end
      end
    end
  end

  describe 'pacbio_aliquot_data:revert_pool_data' do
    it 'deletes all aliquots' do
      # Create some pools with wells
      wells = create_list(:pacbio_well, 5, pool_count: 2, aliquots: [])
      wells.map(&:pools).flatten

      # Run the inital migration rake task, reenable it and invoke it again
      Rake::Task['pacbio_aliquot_data:migrate_pool_data'].reenable
      Rake::Task['pacbio_aliquot_data:migrate_pool_data'].invoke

      # Should be 10 primary aliquots and 10 derived aliquots
      expect(Aliquot.count).to eq(20)

      # Run the revert task
      # It outputs the correct text
      expect { Rake::Task['pacbio_aliquot_data:revert_pool_data'].invoke }.to output(
        <<~HEREDOC
          -> Deleting all aliquots
        HEREDOC
      ).to_stdout
        .and change(Aliquot, :count).from(20).to(0)
    end
  end
end
