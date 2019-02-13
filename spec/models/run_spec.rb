require "rails_helper"

RSpec.describe Run, type: :model do

  context 'on creation' do
    it 'state is nil' do
      run = create(:run)
      expect(run.state.nil?).to be_truthy
    end

    it 'created_at is set' do
      run = create(:run)
      expect(run.created_at).to be_present
    end

    it 'is active' do
      run = create(:run)
      expect(run).to be_active
    end
  end

  context 'chip' do
    it 'can have a chip' do
      run = create(:run)
      chip = create(:chip, run: run)
      expect(run.chip).to eq chip
    end
  end

  context 'state' do
    it 'can change the state to pending' do
      run = create(:run)
      run.pending!
      expect(run.state).to eq "pending"
      expect(run.pending?).to be_truthy
    end

    it 'can change the state to started' do
      run = create(:run)
      run.started!
      expect(run.state).to eq "started"
      expect(run.started?).to be_truthy
    end

    it 'can change the state to completed' do
      run = create(:run)
      run.completed!
      expect(run.state).to eq "completed"
      expect(run.completed?).to be_truthy
    end

    it 'can change the state to cancelled' do
      run = create(:run)
      run.cancelled!
      expect(run.state).to eq "cancelled"
      expect(run.cancelled?).to be_truthy
    end

    it 'can filter runs based on state' do
      pending_run1 = create(:run, state: :pending)
      pending_run2 = create(:run, state: :pending)
      started_run = create(:run, state: :started)
      expect(Run.pending.length).to eq 2
      expect(Run.started.length).to eq 1
    end
  end

  context '#cancel' do
    it 'can be cancelled' do
      run = create(:run)
      run.cancel
      expect(run.deactivated_at).to be_present
      expect(run).not_to be_active
    end

    it 'returns true if already cancelled' do
      run = create(:run)
      run.cancel
      expect(run.cancel).to eq true
    end
  end

  context 'scope' do
    context 'active' do
      it 'should return only active runs' do
        run = create(:run)
        run = create(:run)
        run = create(:run, deactivated_at: DateTime.now)
        expect(Run.active.length).to eq 2
      end
    end
  end

  context 'run relationships' do
    it 'can have a chip with two flowcells each with a library' do
      run = create(:run)
      chip = create(:chip, run: run)
      flowcell1 = create(:flowcell, chip: chip, position: 1)
      flowcell2 = create(:flowcell, chip: chip, position: 2)
      library1 = create(:library, flowcell: flowcell1)
      library2 = create(:library, flowcell: flowcell2)

      expect(run.chip).to eq chip
      expect(run.chip.flowcells).to eq [flowcell1, flowcell2]
      expect(run.chip.flowcells[0].library).to eq(library1)
      expect(run.chip.flowcells[1].library).to eq(library2)
    end
  end

end
