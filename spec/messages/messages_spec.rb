require "rails_helper"

RSpec.describe Messages, type: :model do

  describe '#publish' do

    let(:run)         { create(:run_with_chip) }
    let(:flowcell1)   { create(:flowcell_with_library, chip: run.chip)}
    let(:flowcell2)   { create(:flowcell_with_library, chip: run.chip)}

    before(:all) do
      Pipelines.configure(Rails.configuration.pipelines)
    end

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
