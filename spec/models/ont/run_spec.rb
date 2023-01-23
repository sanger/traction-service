# frozen_string_literal: true

require 'rails_helper'
require './spec/support/read_only'

RSpec.describe Ont::Run, ont: true do
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
      prefix = described_class::NAME_PREFIX
      expect(run.experiment_name).to eq("#{prefix}#{run.id}")
    end

    it 'has a UUID field' do
      run = create(:ont_run)
      expect(run.has_attribute?(:uuid)).to be true
      expect(run.uuid).to be_present
    end
  end

  context 'run' do
    it 'must have a valid instrument' do
      run = build(:ont_run, instrument: nil)
      expect(run).not_to be_valid
    end

    it 'must have a valid instrument id' do
      run = build(:ont_run, instrument: nil)
      run.ont_instrument_id = -1
      expect(run).not_to be_valid
      expect(run.errors.full_messages_for(:instrument)[0]).to eq('Instrument must exist')
    end
  end

  context 'flowcells' do
    it 'must not have more than max_number flowcells' do
      run = build(:ont_gridion_run, flowcell_count: 5)
      expect(run).to be_valid # max number of flowcells

      build(:ont_flowcell, run:)
      expect(run).not_to be_valid # one more than max number of flowcells
      expect(run.errors[:flowcells]).to include('number of flowcells must be less than instrument max number')
    end

    it 'must have unique flowcell position for a run' do
      run = build(:ont_gridion_run, flowcell_count: 2)
      position = run.flowcells[0].position = run.flowcells[1].position = 2

      expect(run).not_to be_valid
      expect(run.errors[:flowcells]).to include("position #{position} is duplicated in the same run")
    end

    it 'can have duplicate flowcell pool id for a run' do
      run = build(:ont_gridion_run, flowcell_count: 2)
      run.flowcells[0].ont_pool_id = run.flowcells[1].ont_pool_id

      expect(run).to be_valid
    end

    it 'must have unique flowcell_id in the run' do
      run = create(:ont_gridion_run, flowcell_count: 2)
      run.flowcells[0].flowcell_id = run.flowcells[1].flowcell_id

      expect(run).not_to be_valid
    end
  end

  context 'experiment name' do
    it 'persists a default experiment_name' do
      run = create(:ont_run)
      experiment_name = run.experiment_name # "ONTRUN-#{id}"
      run.save!

      run.reload
      expect(run.experiment_name).to eq(experiment_name)
    end
  end

  context 'state' do
    it 'can change the state to pending' do
      run = create(:ont_run)
      run.pending!
      expect(run).to be_pending
    end

    it 'can change the state to completed' do
      run = create(:ont_run)
      run.completed!
      expect(run).to be_completed
    end

    it 'can change the state to user_terminated' do
      run = create(:ont_run)
      run.user_terminated!
      expect(run).to be_user_terminated
    end

    it 'can change the state to instrument_crashed' do
      run = create(:ont_run)
      run.instrument_crashed!
      expect(run).to be_instrument_crashed
    end

    it 'can change the state to restart' do
      run = create(:ont_run)
      run.restart!
      expect(run).to be_restart
    end

    it 'can filter runs based on state' do
      instrument = create(:ont_instrument)
      create_list(:ont_run, 2, state: :user_terminated, instrument:)
      create(:ont_run, state: :completed, instrument:)
      expect(described_class.user_terminated.length).to eq 2
      expect(described_class.completed.length).to eq 1
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
        instrument = create(:ont_instrument)
        create_list(:ont_run, 2, instrument:)
        create(:ont_run, deactivated_at: DateTime.now, instrument:)
        expect(described_class.active.length).to eq 2
      end
    end
  end

  describe 'flowcell_attributes' do
    context 'with new flowcells' do
      # new run; no flowcells added yet
      let(:run) { build(:ont_gridion_run, flowcell_count: 0) }
      let(:pool1) { create(:ont_pool) }
      let(:pool2) { create(:ont_pool) }
      let(:flowcell_attributes) do
        [
          { flowcell_id: 'F1', position: 1, ont_pool_id: pool1.id },
          { flowcell_id: 'F2', position: 2, ont_pool_id: pool2.id }
        ]
      end

      it 'sets up flowcells' do
        # Before creating run with new flowcells
        expect(run.flowcells.length).to eq(0)

        # Assign flowcell attributes
        run.flowcell_attributes = flowcell_attributes

        # After creating run with new flowcells
        expect(run.flowcells.length).to eq(2)
      end

      it 'persists flowcells' do
        # Before creating run with new flowcells
        expect(run.id).to be_falsy
        expect(run.flowcells).to be_empty

        # Assign flowcell attributes
        run.flowcell_attributes = flowcell_attributes
        run.save!

        # After creating run with new flowcells
        expect(run.id).to be_truthy
        expect(run.flowcells[0].id).to be_truthy
        expect(run.flowcells[1].id).to be_truthy
      end
    end

    context 'with existing flowcells' do
      # existing run with two flowcells; already persisted
      let(:run) { create(:ont_gridion_run, flowcell_count: 2) }
      let(:fc1) { run.flowcells[0] }
      let(:fc2) { run.flowcells[1] }

      it 'can change existing flowcells' do
        # Second flowcell pool will be changed.
        pool1 = fc1.pool
        pool2 = create(:ont_pool)

        # Second flowcell attributes will be changed.
        attr1 = { id: fc1.id, flowcell_id: fc1.flowcell_id, position: fc1.position, ont_pool_id: fc1.ont_pool_id }
        attr2 = { id: fc2.id, flowcell_id: 'fc2-updated', position: 4, ont_pool_id: pool2.id }
        flowcell_attributes = [attr1, attr2]

        # Update flowcells
        run.flowcell_attributes = flowcell_attributes
        run.save!

        expect(run.flowcells.length).to eq(2)
        expect(run.flowcells).to include(fc1)
        expect(run.flowcells).to include(fc2)

        # First flowcell stays the same.
        expect(fc1.flowcell_id).to eq(attr1[:flowcell_id])
        expect(fc1.position).to eq(attr1[:position])
        expect(fc1.ont_pool_id).to eq(attr1[:ont_pool_id])
        expect(fc1.pool).to eq(pool1)

        # Second flowcell has been changed.
        expect(fc2.flowcell_id).to eq(attr2[:flowcell_id])
        expect(fc2.position).to eq(attr2[:position])
        expect(fc2.ont_pool_id).to eq(attr2[:ont_pool_id])
        expect(fc2.pool).to eq(pool2)
      end

      it 'can remove existing flowcells' do
        # Keep the first flowcell attributes
        attr1 = { id: fc1.id, flowcell_id: fc1.flowcell_id, position: fc1.position, ont_pool_id: fc1.ont_pool_id }
        # Exclude the second flowcell for removing
        flowcell_attributes = [attr1]

        # Update flowcells
        run.flowcell_attributes = flowcell_attributes
        run.save!

        # First flowcell stays the same
        expect(run.flowcells).to include(fc1)
        expect(fc1.flowcell_id).to eq(attr1[:flowcell_id])
        expect(fc1.position).to eq(attr1[:position])
        expect(fc1.ont_pool_id).to eq(attr1[:ont_pool_id])

        # Second flowcell has been removed
        expect(run.flowcells.length).to eq(1)
        expect(run.flowcells).not_to include(fc2)
      end

      it 'can add new flowcells' do
        pool1 = fc1.pool
        pool2 = fc2.pool
        pool3 = create(:ont_pool)

        # Add a third flowcell
        attr1 = { id: fc1.id, flowcell_id: fc1.flowcell_id, position: fc1.position, ont_pool_id: fc1.ont_pool_id }
        attr2 = { id: fc2.id, flowcell_id: fc2.flowcell_id, position: fc2.position, ont_pool_id: fc2.ont_pool_id }
        attr3 = { flowcell_id: 'F3', position: 3, ont_pool_id: pool3.id }
        flowcell_attributes = [attr1, attr2, attr3]

        # Update flowcells
        run.flowcell_attributes = flowcell_attributes
        run.save!

        # First flowcell stays the same
        expect(fc1.flowcell_id).to eq(attr1[:flowcell_id])
        expect(fc1.position).to eq(attr1[:position])
        expect(fc1.ont_pool_id).to eq(attr1[:ont_pool_id])
        expect(fc1.pool).to eq(pool1)

        # Second flowcell stays the same
        expect(fc2.flowcell_id).to eq(attr2[:flowcell_id])
        expect(fc2.position).to eq(attr2[:position])
        expect(fc2.ont_pool_id).to eq(attr2[:ont_pool_id])
        expect(fc2.pool).to eq(pool2)

        # Third flowcell has been added.
        expect(run.flowcells.length).to eq(3)

        fc3 = run.flowcells.find_by(position: 3)
        expect(fc3).to be_truthy
        expect(fc3.id).to be_truthy
        expect(fc3.flowcell_id).to eq(attr3[:flowcell_id])
        expect(fc3.position).to eq(attr3[:position])
        expect(fc3.ont_pool_id).to eq(attr3[:ont_pool_id])
        expect(fc3.pool).to eq(pool3)
      end
    end

    context 'with transformation' do
      let(:run) { create(:ont_gridion_run, flowcell_count: 1) }
      let(:fc1) { run.flowcells[0] }

      it 'converts flowcell_id to uppercase' do
        flowcell_id_input = 'UpPeRcAseD'
        attr = { id: fc1.id, flowcell_id: flowcell_id_input, position: fc1.position, ont_pool_id: fc1.ont_pool_id }

        run.flowcell_attributes = [attr]
        run.save!

        expect(fc1.flowcell_id).to eq(flowcell_id_input.upcase)
      end

      it 'removes leading and trailing whitespace from flowcell_id' do
        flowcell_id_input = " \b \v \t   NOWHITESPACE    \n\r  "
        attr = { id: fc1.id, flowcell_id: flowcell_id_input, position: fc1.position, ont_pool_id: fc1.ont_pool_id }

        run.flowcell_attributes = [attr]
        run.save!

        expect(fc1.flowcell_id).to eq(flowcell_id_input.strip)
      end
    end
  end
end
