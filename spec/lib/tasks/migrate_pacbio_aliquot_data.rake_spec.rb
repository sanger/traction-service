# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# only load Rake tasks if they haven't been loaded already
Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'RakeTasks' do
  before do
    Pacbio::SmrtLinkVersion.find_by(name: 'v12_sequel_iie') || create(:pacbio_smrt_link_version, name: 'v12_sequel_iie', default: true)
  end

  describe 'pacbio_aliquot_data:migrate_request_data' do
    it 'creates primary aliquots for each request' do
      # Create some requests
      requests = create_list(:pacbio_request, 5)
      # Get rid of aliquots that were created by the factory
      requests.map(&:primary_aliquot).flatten.each(&:destroy)

      # Run the rake task
      # It outputs the correct text
      expect { Rake::Task['pacbio_aliquot_data:migrate_request_data'].invoke }.to output(
        <<~HEREDOC
          -> Creating primary aliquots for all requests
        HEREDOC
      ).to_stdout

      # Check if the primary aliquots have been created
      requests.each do |request|
        # Reload the request to get the updated data after the rake task has been run
        request.reload
        expect(request.primary_aliquot.volume).to be_nil
        expect(request.primary_aliquot.concentration).to be_nil
        expect(request.primary_aliquot.template_prep_kit_box_barcode).to be_nil
        expect(request.primary_aliquot.insert_size).to be_nil
      end
    end

    it 'doesnt create primary aliquots for ont requests' do
      # Create some ont requests
      create_list(:ont_request, 5)

      # Run the rake task
      # It outputs the correct text
      Rake::Task['pacbio_aliquot_data:migrate_request_data'].reenable
      expect { Rake::Task['pacbio_aliquot_data:migrate_request_data'].invoke }.to output(
        <<~HEREDOC
          -> Creating primary aliquots for all requests
        HEREDOC
      ).to_stdout

      expect(Aliquot.count).to eq(0)
    end
  end

  describe 'pacbio_aliquot_data:revert_request_data' do
    it 'destroys primary aliquots for each request' do
      # Create some requests
      requests = create_list(:pacbio_request, 5)
      # Create some extra aliquots (aliquots are automatically created when a library is created)
      create_list(:pacbio_library, 5)
      # Get rid of aliquots that were created by the factory
      requests.map(&:primary_aliquot).flatten.each(&:destroy)

      # Run the rake task
      # It outputs the correct text
      expect { Rake::Task['pacbio_aliquot_data:revert_request_data'].invoke }.to output(
        <<~HEREDOC
          -> Deleting all request primary aliquots
        HEREDOC
      ).to_stdout.and change(Aliquot, :count).from(15).to(10)
    end
  end

  describe 'pacbio_aliquot_data:migrate_library_data' do
    it 'creates primary aliquots for each library and request used in the library' do
      # Create some singled-plexed pools (new libraries) with wells
      plate = build(:pacbio_plate_with_wells)
      pools = create_list(:pacbio_pool, 5, library_count: 1, wells: [plate.wells.first], created_at: 1.day.ago.round)
      create(:pacbio_run, plates: [plate])

      # Create some multiplexed pools (these shouldnt be affected)
      create_list(:pacbio_pool, 5, library_count: 2)

      # Get rid of aliquots that were created by the factory
      pools.each do |pool|
        pool.libraries.map(&:primary_aliquot).flatten.each(&:destroy)
        pool.libraries.map(&:used_aliquots).flatten.each(&:destroy)
      end

      # Run the rake task
      # It outputs the correct text
      expect { Rake::Task['pacbio_aliquot_data:migrate_library_data'].invoke }.to output(
        <<~HEREDOC
          -> Creating primary aliquots for all libraries and derived aliquots for all requests used in libraries
        HEREDOC
      ).to_stdout

      # Check if the primary and derived aliquots have been created
      pools.each do |pool|
        # We created a new library which we can find via the tube
        library = Pacbio::Library.find_by(tube: pool.tube)
        expect(library.created_at).to eq(pool.created_at)

        # Reload the library to get the updated data after the rake task has been run
        expect(library.primary_aliquot.volume).to eq(library.volume)
        expect(library.primary_aliquot.concentration).to eq(library.concentration)
        expect(library.primary_aliquot.template_prep_kit_box_barcode).to eq(library.template_prep_kit_box_barcode)
        expect(library.primary_aliquot.insert_size).to eq(library.insert_size)
        expect(library.primary_aliquot.tag).to eq(library.tag)

        expect(library.used_aliquots.length).to eq(1)
        expect(library.used_aliquots).to include(library.request.derived_aliquots.first)

        pool.wells.each do |well|
          well.reload
          expect(well.libraries).to include(library)
        end
      end
    end
  end

  describe 'pacbio_aliquot_data:migrate_pool_data' do
    it 'creates primary aliquots for each pool and request used in the pool' do
      # Create some pools with wells
      wells = create_list(:pacbio_well, 5, pool_count: 2)
      pools = wells.map(&:pools).flatten
      pool_missing_data = pools.first
      pool_missing_data.update!(volume: nil, concentration: nil, template_prep_kit_box_barcode: nil, insert_size: nil)

      # Get rid of aliquots that were created by the factory
      Aliquot.destroy_all

      # Run the rake task
      # It outputs the correct text
      expect { Rake::Task['pacbio_aliquot_data:migrate_pool_data'].invoke }.to output(
        <<~HEREDOC
          -> Creating primary aliquots for all pools and derived aliquots for all requests used in pools
        HEREDOC
      ).to_stdout

      # Check pool defaults have been applied
      pool_missing_data.reload
      expect(pool_missing_data.volume).to eq(0)
      expect(pool_missing_data.concentration).to eq(0)
      expect(pool_missing_data.template_prep_kit_box_barcode).to eq('033000000000000000000')

      # Check if the primary and derived aliquots have been created
      pools.each do |pool|
        # Reload the pool to get the updated data after the rake task has been run
        pool.reload
        expect(pool.primary_aliquot.volume).to eq(pool.volume)
        expect(pool.primary_aliquot.concentration).to eq(pool.concentration)
        expect(pool.primary_aliquot.template_prep_kit_box_barcode).to eq(pool.template_prep_kit_box_barcode)
        expect(pool.primary_aliquot.insert_size).to eq(pool.insert_size)

        pool.libraries.each do |library|
          matched_used_aliquot = pool.used_aliquots.find_by(source: library.request)
          expect(library.request.derived_aliquots).to include(matched_used_aliquot)
          expect(library.tag).to eq(matched_used_aliquot.tag)
          expect(library.volume).to eq(matched_used_aliquot.volume)
          expect(library.concentration).to eq(matched_used_aliquot.concentration)
          expect(library.template_prep_kit_box_barcode).to eq(matched_used_aliquot.template_prep_kit_box_barcode)
          expect(library.insert_size).to eq(matched_used_aliquot.insert_size)
        end
      end
    end
  end

  describe 'pacbio_aliquot_data:revert_pool_data' do
    it 'deletes primary and used aliquots for each pool' do
      # Create some pools with wells
      create_list(:pacbio_well, 5, pool_count: 2)

      # Get rid of aliquots that were created by the factory
      Aliquot.destroy_all

      # Run the rake task
      # It outputs the correct text
      Rake::Task['pacbio_aliquot_data:migrate_pool_data'].reenable
      expect { Rake::Task['pacbio_aliquot_data:migrate_pool_data'].invoke }.to output(
        <<~HEREDOC
          -> Creating primary aliquots for all pools and derived aliquots for all requests used in pools
        HEREDOC
      ).to_stdout

      # Run the revert task
      # It outputs the correct text
      expect { Rake::Task['pacbio_aliquot_data:revert_pool_data'].invoke }.to output(
        <<~HEREDOC
          -> Deleting all pool primary and used aliquots
        HEREDOC
      ).to_stdout
        .and change(Aliquot, :count).from(20).to(0)

      expect(Pacbio::Pool.all.select { |pool| pool.primary_aliquot.present? }).to be_empty
      expect(Pacbio::Pool.all.map(&:used_aliquots).flatten).to be_empty
    end
  end

  describe 'pacbio_aliquot_data:migrate_well_data' do
    it 'creates derived aliquots for each library/pool used in a well' do
      # Create some wells with libraries and pools
      wells = create_list(:pacbio_well, 5, pool_count: 2, library_count: 2)

      # Clear any aliquots created from the factories
      Aliquot.destroy_all

      # Run the rake task
      # It outputs the correct text
      expect { Rake::Task['pacbio_aliquot_data:migrate_well_data'].invoke }.to output(
        <<~HEREDOC
          -> Creating used aliquots for all libraries/pools used in wells
        HEREDOC
      ).to_stdout
        # Changes 20 (5 wells * 4 libraries/pools per well * 1 aliquot per library/pool)
        .and change(Aliquot, :count).from(0).to(20)

      # Check if the derived/used aliquots have been created
      wells.each do |well|
        well.libraries.each do |library|
          expect(library.derived_aliquots).to include(well.used_aliquots.find_by(source: library))
        end
        well.pools.each do |pool|
          expect(pool.derived_aliquots).to include(well.used_aliquots.find_by(source: pool))
        end
      end
    end
  end

  describe 'pacbio_aliquot_data:revert_well_data' do
    it 'deletes all used aliquots from wells' do
      # Create some wells with libraries and pools
      create_list(:pacbio_well, 5, pool_count: 2, library_count: 2)

      # Clear any aliquots created from the factories
      Aliquot.destroy_all

      # Run the inital migration rake task, reenable it and invoke it again
      Rake::Task['pacbio_aliquot_data:migrate_well_data'].reenable
      expect { Rake::Task['pacbio_aliquot_data:migrate_well_data'].invoke }.to output(
        <<~HEREDOC
          -> Creating used aliquots for all libraries/pools used in wells
        HEREDOC
      ).to_stdout

      # Run the revert task
      # It outputs the correct text
      expect { Rake::Task['pacbio_aliquot_data:revert_well_data'].invoke }.to output(
        <<~HEREDOC
          -> Deleting all PacBio well used aliquots
        HEREDOC
      ).to_stdout
        .and change(Aliquot, :count).from(20).to(0)
    end
  end

  describe 'pacbio_aliquot_data:revert_all_data' do
    it 'deletes all aliquots' do
      # Create some libraries
      create_list(:pacbio_pool, 5, library_count: 2)
      # Create some pools with wells and libraries
      create_list(:pacbio_well, 5, pool_count: 2)

      # Run the inital migration rake task, reenable it and invoke it again
      Rake::Task['pacbio_aliquot_data:migrate_request_data'].reenable
      Rake::Task['pacbio_aliquot_data:migrate_pool_data'].reenable
      expect { Rake::Task['pacbio_aliquot_data:migrate_request_data'].invoke }.to output(
        <<~HEREDOC
          -> Creating primary aliquots for all requests
        HEREDOC
      ).to_stdout
      expect { Rake::Task['pacbio_aliquot_data:migrate_pool_data'].invoke }.to output(
        <<~HEREDOC
          -> Creating primary aliquots for all pools and derived aliquots for all requests used in pools
        HEREDOC
      ).to_stdout

      # Should be 10 primary aliquots and 10 derived aliquots
      expect(Aliquot.count).to eq(85)

      # Run the revert task
      # It outputs the correct text
      expect { Rake::Task['pacbio_aliquot_data:revert_all_data'].invoke }.to output(
        <<~HEREDOC
          -> Deleting all aliquots
        HEREDOC
      ).to_stdout
        .and change(Aliquot, :count).from(85).to(0)
    end
  end
end
