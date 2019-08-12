require "rails_helper"

RSpec.describe Messages, type: :model do

  describe '#publish' do

    let(:flowcell1)   { create(:saphyr_flowcell_with_library) }
    let(:flowcell2)   { create(:saphyr_flowcell_with_library) }

    it 'will publish a single message' do
      expect(BrokerHandle).to receive(:publish).once
      Messages.publish(flowcell1, Pipelines.saphyr.message)
    end

    it 'can publish multiple messages' do
      expect(BrokerHandle).to receive(:publish).twice
      Messages.publish([flowcell1, flowcell2], Pipelines.saphyr.message)
    end
  end

end
