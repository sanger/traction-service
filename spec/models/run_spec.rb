require 'rails_helper'

RSpec.describe Run, type: :model do

  context 'on creation' do
    it 'state is pending' do
      run = create(:run)
      expect(run).to be_pending
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
      expect(run).to be_pending
    end

    it 'can change the state to started' do
      run = create(:run)
      run.started!
      expect(run).to be_started
    end

    it 'can change the state to completed' do
      run = create(:run)
      run.completed!
      expect(run).to be_completed
    end

    it 'can change the state to cancelled' do
      run = create(:run)
      run.cancelled!
      expect(run).to be_cancelled
    end

    it 'can filter runs based on state' do
      create_list(:run, 2)
      create(:run, state: :started)
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
        create_list(:run, 2)
        run = create(:run, deactivated_at: DateTime.now)
        expect(Run.active.length).to eq 2
      end
    end
  end

  context 'run relationships' do
    it 'can have a chip with two flowcells' do
      run = create(:run)
      chip = create(:chip, run: run)

      expect(run.chip).to eq chip
    end
  end

  context 'name' do
    it 'defaults to id' do
      run = create(:run)
      expect(run.name).to eq(run.id)
    end

    it 'can be changed' do
      run = create(:run, name: 'run1')
      expect(run.name).to eq('run1')
    end
  end

end
