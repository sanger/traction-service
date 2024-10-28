# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# only load Rake tasks if they haven't been loaded already
Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'RakeTasks' do
  # Create a default SMRTLink version to be used by factories
  before do
    Pacbio::SmrtLinkVersion.find_by(name: 'v13_sequel_iie') || create(:pacbio_smrt_link_version, name: 'v13_sequel_iie', default: true)
  end

  describe 'pool_and_library_aliquots:push_data_to_warehouse' do
    define_negated_matcher :not_change, :change
    before do
      allow(Emq::Publisher).to receive(:publish)
      allow(Rails.logger).to receive(:error) # Mock the error method on Rails.logger
      Rake::Task['pool_and_library_aliquots:push_data_to_warehouse'].reenable
    end

    it 'pushes all pool and library primary aliquots to the warehouse' do
      pool = create(:pacbio_pool)
      library = create(:pacbio_library)
      expect(Emq::Publisher).to receive(:publish).with(array_including(pool.primary_aliquot, library.primary_aliquot), instance_of(Pipelines::Configuration::Item), 'volume_tracking')
      expect { Rake::Task['pool_and_library_aliquots:push_data_to_warehouse'].invoke }.to output(
        <<~HEREDOC
          -> Pushing all pool and library aliquots data to the warehouse for volume tracking
          -> Successfully pushed all pool and library aliquots data to the warehouse
        HEREDOC
      ).to_stdout
    end

    it 'pushes Aliquot.where(source_type: \'Pacbio::Request\', used_by_type: \'Pacbio::Library\', aliquot_type: \'derived\'' do
      request = create(:pacbio_request)
      create(:pacbio_library, request:)
      expect(Emq::Publisher).to receive(:publish).with(array_including(request.derived_aliquots.first), instance_of(Pipelines::Configuration::Item), 'volume_tracking')
      expect { Rake::Task['pool_and_library_aliquots:push_data_to_warehouse'].invoke }.to output(
        <<~HEREDOC
          -> Pushing all pool and library aliquots data to the warehouse for volume tracking
          -> Successfully pushed all pool and library aliquots data to the warehouse
        HEREDOC
      ).to_stdout
    end

    it 'pushes all pool and library used aliquots used in a run to the warehouse' do
      pool = create(:pacbio_pool)
      library = create(:pacbio_library)
      wells = [build(:pacbio_well, row: 'A', column: '1', libraries: [library]), build(:pacbio_well, row: 'B', column: '1', pools: [pool])]
      create(:pacbio_revio_run, plates: [build(:pacbio_plate, wells:)])
      used_aliquots = wells.flat_map(&:used_aliquots)
      pool_aliquots = pool.used_aliquots.select { |aliquot| aliquot.source_type == 'Pacbio::Library' }
      expect(Emq::Publisher).to receive(:publish).with(array_including(*used_aliquots, *pool_aliquots), instance_of(Pipelines::Configuration::Item), 'volume_tracking')
      expect { Rake::Task['pool_and_library_aliquots:push_data_to_warehouse'].invoke }.to output(
        <<~HEREDOC
          -> Pushing all pool and library aliquots data to the warehouse for volume tracking
          -> Successfully pushed all pool and library aliquots data to the warehouse
        HEREDOC
      ).to_stdout
    end

    it 'does not push aliquots of Pacbio:Pool that are not used in Pacbio::Well to the warehouse' do
      library = create(:pacbio_library, volume: 100)
      pool = build(:pacbio_pool, used_aliquots: [build(:aliquot, source: library, volume: 100, aliquot_type: :derived)])
      wells = [build(:pacbio_well, row: 'A', column: '1', pools: [create(:pacbio_pool)])]
      create(:pacbio_revio_run, plates: [build(:pacbio_plate, wells:)])
      pool_aliquots = pool.used_aliquots.select { |aliquot| aliquot.source_type == 'Pacbio::Library' }
      expect(Emq::Publisher).not_to receive(:publish).with(array_including(*pool_aliquots), instance_of(Pipelines::Configuration::Item), 'volume_tracking')
      expect { Rake::Task['pool_and_library_aliquots:push_data_to_warehouse'].invoke }.to output(
        <<~HEREDOC
          -> Pushing all pool and library aliquots data to the warehouse for volume tracking
          -> Successfully pushed all pool and library aliquots data to the warehouse
        HEREDOC
      ).to_stdout
    end

    it 'logs and prints an error message when publishing fails' do
      error_message = 'Test error'
      allow(Emq::Publisher).to receive(:publish).and_raise(StandardError.new(error_message))
      expect(Rails.logger).to receive(:error).with("Failed to publish message: #{error_message}")

      expect { Rake::Task['pool_and_library_aliquots:push_data_to_warehouse'].invoke }.to output(
        <<~HEREDOC
          -> Pushing all pool and library aliquots data to the warehouse for volume tracking
          -> Failed to push aliquots data to the warehouse: #{error_message}
        HEREDOC
      ).to_stdout
    end
  end
end
