# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublishPacbioRunMessageJob do
  before do
    create(:pacbio_smrt_link_version_default, name: 'v13_revio')
  end

  describe '#perform' do
    let(:run) { create(:pacbio_revio_run) }

    it 'publishes the warehouse run message and volume-tracking messages' do
      aliquots = run.aliquots_to_publish_on_run

      expect(Messages).to receive(:publish).with(instance_of(Pacbio::Run), having_attributes(pipeline: 'pacbio'))
      expect(Emq::Publisher).to receive(:publish).with(aliquots, having_attributes(pipeline: 'pacbio'), 'volume_tracking')

      described_class.perform_now(run.id)
    end

    it 'raises the error and skips volume tracking if publishing the run message fails' do
      allow(Messages).to receive(:publish).with(instance_of(Pacbio::Run), having_attributes(pipeline: 'pacbio'))
                                          .and_raise(StandardError, 'Failed to publish run message')
      expect(Emq::Publisher).not_to receive(:publish)

      expect { described_class.perform_now(run.id) }
        .to raise_error(StandardError, 'Failed to publish run message')
    end

    it 'raises the error if publishing volume-tracking messages fails' do
      aliquots = run.aliquots_to_publish_on_run

      expect(Messages).to receive(:publish).with(instance_of(Pacbio::Run), having_attributes(pipeline: 'pacbio'))
      allow(Emq::Publisher).to receive(:publish).with(aliquots, having_attributes(pipeline: 'pacbio'), 'volume_tracking')
                                                .and_raise(StandardError, 'Failed to publish volume-tracking messages')

      expect { described_class.perform_now(run.id) }
        .to raise_error(StandardError, 'Failed to publish volume-tracking messages')
    end

    it 'does nothing if the run no longer exists' do
      expect(Messages).not_to receive(:publish)
      expect(Emq::Publisher).not_to receive(:publish)

      described_class.perform_now(-1)
    end
  end
end
