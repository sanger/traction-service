# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::RunFactory do
  let!(:smrt_link_version) do
    # Create a default pacbio smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v11', default: true)
  end

  describe '#construct_resources!' do
    subject(:construct_resources) do
      run_factory.construct_resources!
    end

    let(:run_factory) do
      build(:pacbio_run_factory, run_attributes:, well_attributes:)
    end

    context 'create' do
      let!(:pools) { [create(:pacbio_pool), create(:pacbio_pool)] }
      let(:run_attributes) { attributes_for(:pacbio_run).merge(pacbio_smrt_link_version_id: smrt_link_version.id) }
      let(:well_attributes) { [attributes_for(:pacbio_well).except(:plate, :pools, :run).merge(pools: pools.collect(&:id)).with_indifferent_access] }

      it 'creates a run' do
        expect { construct_resources }.to change(Pacbio::Run, :count).by(1)
      end

      it 'creates a plate' do
        expect { construct_resources }.to change(Pacbio::Plate, :count).by(1)
      end

      it 'creates a well' do
        expect { construct_resources }.to change(Pacbio::Well, :count).by(1)
      end

      it 'attaches pools to the well' do
        construct_resources
        expect(Pacbio::Well.first.pools.count).to eq(pools.length)
        expect(Pacbio::Well.first.pools.first).to eq(pools.first)
        expect(Pacbio::Well.first.pools.last).to eq(pools.last)
      end
    end

    context 'update run' do
      let!(:run) { create(:pacbio_run, plates: [create(:pacbio_plate)]) }
      let(:run_attributes) { { id: run.id, sequencing_kit_box_barcode: 'DMXXX' } }
      let(:well_attributes) { nil }

      it 'modifies the attributes' do
        construct_resources
        run.reload
        expect(run.sequencing_kit_box_barcode).to eq('DMXXX')
      end

      it 'does not create a new run' do
        expect { construct_resources }.not_to change(Pacbio::Run, :count)
      end

      it 'does not create a new plate' do
        expect { construct_resources }.not_to change(Pacbio::Plate, :count)
      end
    end

    context 'update wells' do
      let!(:wells) { [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'B', column: '1')] }
      let!(:run) { create(:pacbio_run, plates: [create(:pacbio_plate, wells:)]) }
      let!(:run_attributes) { { id: run.id } }
      let!(:pool) { create(:pacbio_pool) }

      it 'updates existing wells' do
        well_attributes = run.plates.first.wells.collect { |well| well.attributes.with_indifferent_access }
        well_attributes.first.merge!(pools: [pool.id])
        run_factory = build(:pacbio_run_factory, run_attributes:, well_attributes:)
        run_factory.construct_resources!
        run.reload
        expect(run.plates.first.wells.find_by(row: 'A', column: '1').pools).to eq([pool])
      end

      it 'creates new wells' do
        well_attributes = run.plates.first.wells.collect { |well| well.attributes.with_indifferent_access }
        well_attributes << build(:pacbio_well, row: 'C', column: '1').attributes.merge(pools: [pool.id]).with_indifferent_access
        run_factory = build(:pacbio_run_factory, run_attributes:, well_attributes:)
        run_factory.construct_resources!
        run.reload
        expect(run.plates.first.wells.count).to eq(3)
      end

      it 'deletes wells that are no longer exist', skip: 'Not implemented' do
        well_attributes = run.plates.first.wells.collect { |well| well.attributes.with_indifferent_access }
        well_attributes.pop
        run_factory = build(:pacbio_run_factory, run_attributes:, well_attributes:)
        run_factory.construct_resources!
        run.reload
        expect(run.plates.first.wells.count).to eq(1)
      end
    end
  end

  describe 'with invalid run' do
    subject(:run_factory) { build(:pacbio_run_factory, run_attributes:, well_attributes:) }

    let(:run_attributes)  { attributes_for(:pacbio_run).merge(pacbio_smrt_link_version_id: smrt_link_version.id, sequencing_kit_box_barcode: nil) }
    let(:well_attributes) { [attributes_for(:pacbio_well).except(:plate, :pools, :run)] }

    it { is_expected.to be_invalid }
  end

  describe 'with invalid well' do
    subject(:run_factory) { build(:pacbio_run_factory, run_attributes:, well_attributes:) }

    let(:run_attributes)  { attributes_for(:pacbio_run).merge(pacbio_smrt_link_version_id: smrt_link_version.id) }
    let(:well_attributes) { [attributes_for(:pacbio_well).except(:plate, :pools, :run).merge(row: nil)] }

    it { is_expected.to be_invalid }
  end
end
