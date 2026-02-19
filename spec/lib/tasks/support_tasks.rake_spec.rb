# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# only load Rake tasks if they haven't been loaded already
Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'RakeTasks' do
  before do
    Pacbio::SmrtLinkVersion.find_by(name: 'v13_revio') || create(:pacbio_smrt_link_version, name: 'v13_revio', default: true)
  end

  describe 'pacbio_library_sample_swap' do
    before do
      create(:library_type, :pacbio)
    end

    it 'outputs a warning and does if one or both library ids are invalid' do
      Rake::Task['support_tasks:pacbio_library_sample_swap'].reenable

      expect { Rake::Task['support_tasks:pacbio_library_sample_swap'].invoke('nonId', 'nonId2') }.to output(
        <<~HEREDOC
          Warning: Could not find library with id nonId
          Warning: Could not find library with id nonId2
        HEREDOC
      ).to_stdout
    end

    it 'correctly swaps the libraries samples and rebroadcasts the correct messages (no runs, no pools)' do
      Rake::Task['support_tasks:pacbio_library_sample_swap'].reenable

      library1 = create(:pacbio_library)
      library2 = create(:pacbio_library)
      request1 = library1.request
      request2 = library2.request

      # Published twice, onces for each library
      expect(Emq::Publisher).to receive(:publish).twice.with(anything, having_attributes(pipeline: 'pacbio'), 'volume_tracking')

      expect { Rake::Task['support_tasks:pacbio_library_sample_swap'].invoke(library1.id, library2.id) }.to output(
        <<~HEREDOC
          -> Swapped samples of libraries #{library1.id} and #{library2.id}
        HEREDOC
      ).to_stdout

      library1.reload
      library2.reload

      expect(library1.request).to eq(request2)
      expect(library1.used_aliquots.first.source_id).to eq(request2.id)
      expect(library2.request).to eq(request1)
      expect(library2.used_aliquots.first.source_id).to eq(request1.id)
    end

    it 'correctly swaps the libraries samples and rebroadcasts the correct messages (runs, no pools)' do
      Rake::Task['support_tasks:pacbio_library_sample_swap'].reenable

      library1 = create(:pacbio_library)
      library2 = create(:pacbio_library)
      request1 = library1.request
      request2 = library2.request
      # Creates runs using the library
      run1 = create(:pacbio_revio_run)
      run2 = create(:pacbio_revio_run)
      create(:pacbio_well, libraries: [library1], plate: run1.plates.first)
      create(:pacbio_well, libraries: [library2], plate: run2.plates.first)

      # Published 4 times
      # once for each library
      # once for each run
      expect(Emq::Publisher).to receive(:publish).exactly(4).times.with(anything, having_attributes(pipeline: 'pacbio'), 'volume_tracking')
      # Runs that the library is in as the sample has changed
      expect(Messages).to receive(:publish).with(run1, having_attributes(pipeline: 'pacbio'))
      expect(Messages).to receive(:publish).with(run2, having_attributes(pipeline: 'pacbio'))

      expect { Rake::Task['support_tasks:pacbio_library_sample_swap'].invoke(library1.id, library2.id) }.to output(
        <<~HEREDOC
          -> Republishing run data and volume tracking messages for run #{run1.name}
          -> Republishing run data and volume tracking messages for run #{run2.name}
          -> Swapped samples of libraries #{library1.id} and #{library2.id}
        HEREDOC
      ).to_stdout

      library1.reload
      library2.reload

      expect(library1.request).to eq(request2)
      expect(library1.used_aliquots.first.source_id).to eq(request2.id)
      expect(library2.request).to eq(request1)
      expect(library2.used_aliquots.first.source_id).to eq(request1.id)
    end

    it 'correctly swaps the libraries samples and rebroadcasts the correct messages (runs, pools)' do
      Rake::Task['support_tasks:pacbio_library_sample_swap'].reenable

      # Create pools and libraries
      pool1 = create(:pacbio_pool, :tagged, library_count: 1)
      library1 = pool1.libraries.first
      pool2 = create(:pacbio_pool, :tagged, library_count: 1)
      library2 = pool2.libraries.first
      request1 = library1.request
      request2 = library2.request

      # Creates runs using the library
      run1 = create(:pacbio_revio_run)
      run2 = create(:pacbio_revio_run)
      create(:pacbio_well, libraries: [library1], plate: run1.plates.first)
      create(:pacbio_well, libraries: [library2], plate: run2.plates.first)
      # Create runs using the pools
      run3 = create(:pacbio_revio_run)
      run4 = create(:pacbio_revio_run)
      create(:pacbio_well, pools: [pool1], plate: run3.plates.first)
      create(:pacbio_well, pools: [pool2], plate: run4.plates.first)

      # Published 6 times
      # once for each library
      # once for each run
      expect(Emq::Publisher).to receive(:publish).exactly(6).times.with(anything, having_attributes(pipeline: 'pacbio'), 'volume_tracking')
      # Runs that the library is in as the sample has changed
      expect(Messages).to receive(:publish).with(run1, having_attributes(pipeline: 'pacbio'))
      expect(Messages).to receive(:publish).with(run2, having_attributes(pipeline: 'pacbio'))
      expect(Messages).to receive(:publish).with(run3, having_attributes(pipeline: 'pacbio'))
      expect(Messages).to receive(:publish).with(run4, having_attributes(pipeline: 'pacbio'))

      # Note run order is because it goes library and library pools runs before moving onto the next library
      expect { Rake::Task['support_tasks:pacbio_library_sample_swap'].invoke(library1.id, library2.id) }.to output(
        <<~HEREDOC
          -> Republishing run data and volume tracking messages for run #{run1.name}
          -> Republishing run data and volume tracking messages for run #{run3.name}
          -> Republishing run data and volume tracking messages for run #{run2.name}
          -> Republishing run data and volume tracking messages for run #{run4.name}
          -> Swapped samples of libraries #{library1.id} and #{library2.id}
        HEREDOC
      ).to_stdout

      library1.reload
      library2.reload

      expect(library1.request).to eq(request2)
      expect(library1.used_aliquots.first.source_id).to eq(request2.id)
      expect(library2.request).to eq(request1)
      expect(library2.used_aliquots.first.source_id).to eq(request1.id)
    end
  end
end
