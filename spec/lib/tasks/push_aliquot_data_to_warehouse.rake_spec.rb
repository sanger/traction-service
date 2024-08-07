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

    let(:pool_aliquots) { create_list(:aliquot, 5, source: create(:pacbio_pool)) }
    let(:library_aliquots) { create_list(:aliquot, 5, source: create(:pacbio_library)) }
    let(:request_aliquots) { create_list(:aliquot, 5, source: create(:pacbio_request)) }
    let(:library) { create(:pacbio_library) }
    let(:pool) { create(:pacbio_pool) }

    let(:wells) { [build(:pacbio_well, row: 'A', column: '1', libraries: [library]), build(:pacbio_well, row: 'B', column: '1', pools: [pool])] }

    let(:run) { create(:pacbio_revio_run, plates: [build(:pacbio_plate, wells:)]) }

    before do
      allow(Emq::Publisher).to receive(:publish)
      allow(Rails.logger).to receive(:error) # Mock the error method on Rails.logger
      Rake::Task['pool_and_library_aliquots:push_data_to_warehouse'].reenable
    end

    it 'publishes all aliquots that are not from Pacbio::Request to the warehouse' do
      aliquots_used_in_run = run.plates.flat_map(&:wells).flat_map(&:aliquots)
      expect(Emq::Publisher).to receive(:publish).with(array_including(*library_aliquots, *pool_aliquots, *aliquots_used_in_run), instance_of(Pipelines::Configuration::Item), 'volume_tracking')

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
