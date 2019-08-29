require 'rails_helper'

RSpec.describe Saphyr::Run, type: :model, saphyr: true do

  context 'on creation' do
    it 'state is pending' do
      run = create(:saphyr_run)
      expect(run).to be_pending
    end

    it 'created_at is set' do
      run = create(:saphyr_run)
      expect(run.created_at).to be_present
    end

    it 'is active' do
      run = create(:saphyr_run)
      expect(run).to be_active
    end
  end

  context 'chip' do
    it 'can have a chip' do
      run = create(:saphyr_run)
      chip = create(:saphyr_chip, run: run)
      expect(run.chip).to eq chip
    end
  end

  context 'state' do
    it 'can change the state to pending' do
      run = create(:saphyr_run)
      run.pending!
      expect(run).to be_pending
    end

    it 'can change the state to started' do
      run = create(:saphyr_run)
      run.started!
      expect(run).to be_started
    end

    it 'can change the state to completed' do
      run = create(:saphyr_run)
      run.completed!
      expect(run).to be_completed
    end

    it 'can change the state to cancelled' do
      run = create(:saphyr_run)
      run.cancelled!
      expect(run).to be_cancelled
    end

    it 'can filter runs based on state' do
      create_list(:saphyr_run, 2)
      create(:saphyr_run, state: :started)
      expect(Saphyr::Run.pending.length).to eq 2
      expect(Saphyr::Run.started.length).to eq 1
    end
  end

  context '#cancel' do
    it 'can be cancelled' do
      run = create(:saphyr_run)
      run.cancel
      expect(run.deactivated_at).to be_present
      expect(run).not_to be_active
    end

    it 'returns true if already cancelled' do
      run = create(:saphyr_run)
      run.cancel
      expect(run.cancel).to eq true
    end
  end

  context 'scope' do
    context 'active' do
      it 'should return only active runs' do
        create_list(:saphyr_run, 2)
        run = create(:saphyr_run, deactivated_at: DateTime.now)
        expect(Saphyr::Run.active.length).to eq 2
      end
    end
  end

  context 'run relationships' do
    it 'can have a chip with two flowcells' do
      run = create(:saphyr_run)
      chip = create(:saphyr_chip, run: run)

      expect(run.chip).to eq chip
    end
  end

  context 'name' do
    it 'defaults to id when name is null' do
      run = create(:saphyr_run)
      expect(run.name).to eq(run.id)
    end

    it 'defaults to id when name is an empty string' do
      run = create(:saphyr_run, name: '')
      expect(run.name).to eq(run.id)
    end

    it 'can be changed' do
      run = create(:saphyr_run, name: 'run1')
      expect(run.name).to eq('run1')
    end
  end

end
