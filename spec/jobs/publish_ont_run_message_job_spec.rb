# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublishOntRunMessageJob do
  before do
    create(:ont_min_know_version_default, name: 'v22')
  end

  describe '#perform' do
    let(:run) { create(:ont_gridion_run, flowcell_count: 2) }

    it 'publishes the run message using the ONT pipeline configuration' do
      expect(Messages).to receive(:publish).with(run, having_attributes(pipeline: 'ont'))

      described_class.perform_now(run.id)
    end

    it 'raises the error if publishing the run message fails' do
      allow(Messages).to receive(:publish).with(run, having_attributes(pipeline: 'ont'))
                                          .and_raise(StandardError, 'Failed to publish run message')

      expect { described_class.perform_now(run.id) }
        .to raise_error(StandardError, 'Failed to publish run message')
    end

    it 'does nothing if the run no longer exists' do
      expect(Messages).not_to receive(:publish)

      described_class.perform_now(-1)
    end
  end
end
