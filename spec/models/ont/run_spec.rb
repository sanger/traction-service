require 'rails_helper'

RSpec.describe Ont::Run, type: :model, ont: true do

  context 'on creation' do
    it 'state is pending' do
      run = create(:ont_run)
      expect(run).to be_pending
    end

    it 'created_at is set' do
      run = create(:ont_run)
      expect(run.created_at).to be_present
    end

    it 'is active' do
      run = create(:ont_run)
      expect(run).to be_active
    end

    it 'has an experiment name' do
      run = create(:ont_run)
      expect(run.experiment_name).to eq("ONTRUN-#{run.id}")
    end
  end

  context 'state' do
    it 'can change the state to pending' do
      run = create(:ont_run)
      run.pending!
      expect(run).to be_pending
    end

    it 'can change the state to started' do
      run = create(:ont_run)
      run.started!
      expect(run).to be_started
    end

    it 'can change the state to completed' do
      run = create(:ont_run)
      run.completed!
      expect(run).to be_completed
    end

    it 'can change the state to cancelled' do
      run = create(:ont_run)
      run.cancelled!
      expect(run).to be_cancelled
    end

    it 'can filter runs based on state' do
      create_list(:ont_run, 2)
      create(:ont_run, state: :started)
      expect(Ont::Run.pending.length).to eq 2
      expect(Ont::Run.started.length).to eq 1
    end
  end

  context '#cancel' do
    it 'can be cancelled' do
      run = create(:ont_run)
      run.cancel
      expect(run.deactivated_at).to be_present
      expect(run).not_to be_active
    end

    it 'returns true if already cancelled' do
      run = create(:ont_run)
      run.cancel
      expect(run.cancel).to eq true
    end
  end

  context 'scope' do
    context 'active' do
      it 'should return only active runs' do
        create_list(:ont_run, 2)
        create(:ont_run, deactivated_at: DateTime.now)
        expect(Ont::Run.active.length).to eq 2
      end
    end
  end

  context 'resolved' do
    context 'instance' do
      it 'returns a single run' do
        run = create(:ont_run)
        expect(run.resolved_run).to eq(run)
      end
    end

    context 'class' do
      it 'returns expected includes_args' do
        expect(Ont::Run.includes_args).to eq([flowcells: Ont::Flowcell.includes_args(except: :run)])
      end

      it 'removes keys from includes_args' do
        expect(Ont::Run.includes_args(except: :flowcells)).to be_empty
      end

      it 'returns a single run' do
        run = create(:ont_run)
        expect(Ont::Run.resolved_run(id: run.id)).to eq(run)
      end

      it 'returns all runs' do
        runs = create_list(:ont_run, 3)
        expect(Ont::Run.all_resolved_runs).to match_array(runs)
      end
    end
  end
end
