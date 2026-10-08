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

    it 'does nothing if the run no longer exists' do
      expect(Messages).not_to receive(:publish)
      expect(Emq::Publisher).not_to receive(:publish)

      described_class.perform_now(-1)
    end
  end
end
