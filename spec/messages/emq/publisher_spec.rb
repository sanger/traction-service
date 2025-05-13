# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emq::Publisher do
  describe '#configuration' do
    let(:aliquot) { instance_double(Aliquot) }
    let(:aliquots) { [aliquot] }
    let(:configuration) { double('configuration') }
    let(:schema_key) { 'schema_key' }
    let(:publish_job_mock) { instance_double(Emq::PublishingJob) }

    before do
      allow(Emq::PublishingJob).to receive(:new).and_return(publish_job_mock)
      allow(publish_job_mock).to receive(:publish).with(aliquots, configuration, schema_key)
    end

    context 'when bunny is disabled' do
      before do
        allow(Rails.configuration).to receive(:bunny).and_return({ 'enabled' => false })
      end

      it 'is present' do
        described_class.publish(aliquots, configuration, schema_key)
        expect(described_class.instance_variable_get(:@publish_job)).to be_nil
        expect(publish_job_mock).not_to have_received(:publish).with(aliquots, configuration, schema_key)
      end
    end

    context 'when bunny is enabled' do
      before do
        allow(Rails.configuration).to receive(:bunny).and_return({ 'enabled' => true })
      end

      after do
        described_class.instance_variable_set(:@publish_job, nil)
      end

      it 'is present' do
        described_class.publish(aliquots, configuration, schema_key)
        expect(described_class.instance_variable_get(:@publish_job)).not_to be_nil
        expect(publish_job_mock).to have_received(:publish).with(aliquots, configuration, schema_key)
      end
    end
  end
end
