# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Messages, type: :model do
  describe '#publish' do
    let(:flowcell1)   { create(:saphyr_flowcell_with_library) }
    let(:flowcell2)   { create(:saphyr_flowcell_with_library) }

    it 'publishes a single message' do
      expect(Broker::Handle).to receive(:publish).once
      described_class.publish(flowcell1, Pipelines.saphyr.message)
    end

    it 'can publish multiple messages' do
      expect(Broker::Handle).to receive(:publish).twice
      described_class.publish([flowcell1, flowcell2], Pipelines.saphyr.message)
    end
  end
end
