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
    end

    it 'publishes all aliquots that are not from Pacbio::Request to the warehouse' do
      aliquots_used_in_run = run.plates.flat_map(&:wells).flat_map(&:libraries).flat_map(&:aliquots)
      expect { Rake::Task['pool_and_library_aliquots:push_data_to_warehouse'].invoke }.to output(
        <<~HEREDOC
          -> Pushing all pool and library aliquots data to the warehouse for volume tracking
        HEREDOC
      ).to_stdout

      expect(Emq::Publisher).to have_received(:publish).with(array_including(*library_aliquots, *pool_aliquots, *aliquots_used_in_run), instance_of(Pipelines::Configuration::Item), 'volume_tracking') # rubocop:disable RSpec/MessageSpies
    end

    it 'does not publish Pacbio::Request aliquots to the warehouse' do
      all_request_aliquots = Aliquot.where(source_type: 'Pacbio::Request')
      Rake::Task['pool_and_library_aliquots:push_data_to_warehouse'].invoke

      expect(Emq::Publisher).not_to have_received(:publish).with(include(*all_request_aliquots), instance_of(Pipelines::Configuration::Item), 'volume_tracking') # rubocop:disable RSpec/MessageSpies
    end
  end
end
