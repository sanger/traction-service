require 'rails_helper'

RSpec.describe RunFactory, type: :model do
  let(:run) { create(:run)}
  let(:attributes) { [{ state: 'pending' }]}

  context '#initialise' do
    it 'creates an object for each given run' do
      factory = RunFactory.new(attributes)
      expect(factory.runs.count).to eq(1)
      expect(factory.runs[0].chip).to be_present
    end

  end

  context '#save' do
    it 'creates a run, with a chip and two flowcells for each set of attributes' do
      factory = RunFactory.new(attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(Run.all.count).to eq(attributes.length)
      expect(Run.first.chip.run_id).to eq Run.first.id
      expect(Run.first.chip.flowcells.length).to eq 2
    end

  end

end
