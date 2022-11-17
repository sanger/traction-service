# frozen_string_literal: true

require 'rails_helper'
require './spec/support/read_only'

RSpec.describe Ont::Run, :skip, type: :model, ont: true do
  before do
    set_read_only(described_class, false)
  end

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
      expect(described_class.pending.length).to eq 2
      expect(described_class.started.length).to eq 1
    end
  end

  describe '#cancel' do
    it 'can be cancelled' do
      run = create(:ont_run)
      run.cancel
      expect(run.deactivated_at).to be_present
      expect(run).not_to be_active
    end

    it 'returns true if already cancelled' do
      run = create(:ont_run)
      run.cancel
      expect(run.cancel).to be true
    end
  end

  context 'scope' do
    context 'active' do
      it 'returns only active runs' do
        create_list(:ont_run, 2)
        create(:ont_run, deactivated_at: DateTime.now)
        expect(described_class.active.length).to eq 2
      end
    end
  end
end
