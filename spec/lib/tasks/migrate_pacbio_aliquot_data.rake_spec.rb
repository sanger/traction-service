# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# only load Rake tasks if they haven't been loaded already
Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'RakeTasks' do
  before do
    Pacbio::SmrtLinkVersion.find_by(name: 'v12_sequel_iie') || create(:pacbio_smrt_link_version, name: 'v12_sequel_iie', default: true)
  end

  describe 'pacbio_aliquot_data:migrate_library_data' do
    it 'creates primary and derived aliquots for each library' do
      # Create some libraries with pools
      libraries_with_pools = create_list(:pacbio_library, 5, pool: create(:pacbio_pool), aliquots: [])
      # In theory shouldnt exist but just in case
      libraries_without_pools = create_list(:pacbio_library, 5, pool: nil, aliquots: [])

      expect { Rake::Task['pacbio_aliquot_data:migrate_library_data'].invoke }.to output(
        <<~HEREDOC
          -> Creating primary aliquots for all libraries
        HEREDOC
      ).to_stdout

      # Check if the primary and derived aliquots have been created
      libraries_with_pools.each do |library|
        expect(library.primary_aliquot.volume).to eq(library.volume)
        expect(library.primary_aliquot.concentration).to eq(library.concentration)
        expect(library.primary_aliquot.template_prep_kit_box_barcode).to eq(library.template_prep_kit_box_barcode)
        expect(library.primary_aliquot.insert_size).to eq(library.insert_size)

        library.derived_aliquots.each do |derived_aliquot|
          expect(derived_aliquot.volume).to eq(library.volume)
          expect(derived_aliquot.concentration).to eq(library.concentration)
          expect(derived_aliquot.template_prep_kit_box_barcode).to eq(library.template_prep_kit_box_barcode)
          expect(derived_aliquot.insert_size).to eq(library.insert_size)
        end
      end

      libraries_without_pools.each do |library|
        expect(library.primary_aliquot.volume).to eq(library.volume)
        expect(library.primary_aliquot.concentration).to eq(library.concentration)
        expect(library.primary_aliquot.template_prep_kit_box_barcode).to eq(library.template_prep_kit_box_barcode)
        expect(library.primary_aliquot.insert_size).to eq(library.insert_size)

        expect(library.derived_aliquots).to be_empty
      end
    end
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
        # Reload the pool to get the updated data after the rake task has been run
        pool.reload
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
        # Reload the well to get the updated data after the rake task has been run
        well.reload
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

  describe 'pacbio_aliquot_data:revert_all_data' do
    it 'deletes all aliquots' do
      # Create some libraries
      create_list(:pacbio_pool, 5, library_count: 2)
      # Create some pools with wells and libraries
      create_list(:pacbio_well, 5, pool_count: 2, aliquots: [])

      # Run the inital migration rake task, reenable it and invoke it again
      Rake::Task['pacbio_aliquot_data:migrate_all_data'].reenable
      Rake::Task['pacbio_aliquot_data:migrate_pool_data'].reenable
      Rake::Task['pacbio_aliquot_data:migrate_library_data'].reenable
      expect { Rake::Task['pacbio_aliquot_data:migrate_all_data'].invoke }.to output(
        <<~HEREDOC
          -> Creating primary aliquots for all libraries
          -> Creating primary aliquots for all pools
        HEREDOC
      ).to_stdout

      # Libraries: Should be 20 primary aliquots and 20 (2x10 pools) derived aliquots
      # Pools: Should be 15 primary aliquots and 10 (2x5 wells) derived aliquots
      expect(Aliquot.count).to eq(65)

      # Run the revert task
      # It outputs the correct text
      expect { Rake::Task['pacbio_aliquot_data:revert_all_data'].invoke }.to output(
        <<~HEREDOC
          -> Deleting all aliquots
        HEREDOC
      ).to_stdout
        .and change(Aliquot, :count).from(65).to(0)
    end
  end
end
