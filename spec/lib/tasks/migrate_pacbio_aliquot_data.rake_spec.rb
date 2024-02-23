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

      # Run the rake task
      # It outputs the correct text
      expect { Rake::Task['pacbio_aliquot_data:migrate_pool_data'].invoke }.to output(
        <<~HEREDOC
          -> Creating primary aliquots for all pools and derived aliquots for all requests used in pools
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

        pool.libraries.each do |library|
          expect(library.request.derived_aliquots).to include(pool.used_aliquots.find_by(source: library.request))
        end
      end
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
      expect(Aliquot.count).to eq(75)

      # Run the revert task
      # It outputs the correct text
      expect { Rake::Task['pacbio_aliquot_data:revert_all_data'].invoke }.to output(
        <<~HEREDOC
          -> Deleting all aliquots
        HEREDOC
      ).to_stdout
        .and change(Aliquot, :count).from(75).to(0)
    end
  end
end