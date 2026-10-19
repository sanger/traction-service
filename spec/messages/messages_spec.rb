# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Messages do
  describe '.publish' do
    let(:object) { build(:pacbio_pool) }
    let(:configuration) { Pipelines.pacbio.message }

    before do
      allow(Message::Message).to receive(:new).and_return(instance_double(Message::Message))
    end

    it 'publishes a message for each object' do
      expect(Broker::Handle).to receive(:publish).twice
      described_class.publish([object, object], configuration)
    end

    context 'when the broker raises an error' do
      let(:error) { StandardError.new('connection refused') }

      before do
        allow(Broker::Handle).to receive(:publish).and_raise(error)
      end

      it 'does not raise' do
        expect { described_class.publish(object, configuration) }.not_to raise_error
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error).with('Failed to publish message to RabbitMQ: connection refused')
        described_class.publish(object, configuration)
      end

      it 'sends an exception notification' do
        expect(ExceptionNotifier).to receive(:notify_exception).with(error)
        described_class.publish(object, configuration)
      end
    end
  end
end
