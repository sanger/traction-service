require "rails_helper"

RSpec.describe Messages, type: :model do

  describe '#publish' do

    let(:run)       { create(:run_with_chip) }
    let(:flowcell)  { create(:flowcell_with_library, chip: run.chip)}

    before(:all) do
      Pipelines.configure(Rails.configuration.pipelines)
    end

    it 'will publish a message' do
      expect(BrokerHandle).to receive(:publish)
      Messages.publish(flowcell, Pipelines.saphyr.message)
    end
  end

end
