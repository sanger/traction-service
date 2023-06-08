# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::WellFactory do
  before do
    # Create a default pacbio smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v11', default: true)
  end

  describe.skip '#construct_resources' do
    subject(:construct_resources) do
      well_factory.construct_resources!
    end

    describe '#create' do
      let(:well_factory) do
        build(:pacbio_well_factory, plate:, well_attributes:)
      end

      let!(:plate) { create(:pacbio_plate) }
      let!(:pools) { [create(:pacbio_pool), create(:pacbio_pool)] }
      let(:well_attributes) { [build(:pacbio_well, row: 'A', column: '1').attributes.merge(pools: pools.collect(&:id)).with_indifferent_access] }

      it 'creates a well' do
        expect(well_factory).to be_valid
        expect { construct_resources }.to change(Pacbio::Well, :count).by(1)
      end

      it 'attaches pools to the well' do
        construct_resources
        expect(Pacbio::Well.first.pools.count).to eq(pools.length)
        expect(Pacbio::Well.first.pools.first).to eq(pools.first)
        expect(Pacbio::Well.first.pools.last).to eq(pools.last)
      end

      it 'does not create a run with invalid well positions' do
        well_factory.well_attributes = [build(:pacbio_well, row: 'D', column: '1')]
        expect(well_factory).not_to be_valid
      end

      it 'does not create a run with invalid well contiguousness' do
        well_factory.well_attributes = [
          build(:pacbio_well, row: 'A', column: '1'),
          build(:pacbio_well, row: 'B', column: '1')
        ]
        expect(well_factory).not_to be_valid
      end
    end

    describe '#update' do
      let!(:wells) { [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'B', column: '1')] }
      let(:run) { create(:pacbio_run, plates: [create(:pacbio_plate, wells:)]) }
      let!(:pool) { create(:pacbio_pool) }
      let!(:plate) { create(:pacbio_plate) }

      it 'updates existing wells' do
        well_attributes = run.plates.first.wells.collect { |well| well.attributes.with_indifferent_access }
        well_attributes.first.merge!(pools: [pool.id])
        well_factory = build(:pacbio_well_factory, plate:, well_attributes:)
        well_factory.construct_resources!
        run.reload
        expect(run.plates.first.wells.find_by(row: 'A', column: '1').pools).to eq([pool])
      end

      it 'deletes wells that no longer exist' do
        well_attributes = run.plates.first.wells.collect { |well| well.attributes.with_indifferent_access.merge(pools: well.pools.pluck(:id)) }
        well_attributes.pop
        well_factory = build(:pacbio_well_factory, plate:, well_attributes:)
        well_factory.construct_resources!
        run.reload
        expect(run.plates.first.wells.count).to eq(1)
      end
    end
  end

  describe 'returns the correct output' do
    context 'well factory with existing wells' do
      let!(:plate) { create(:pacbio_plate) }
      let!(:pools) { [create(:pacbio_pool), create(:pacbio_pool)] }
      let(:well_attributes) { [build(:pacbio_well, row: 'A', column: '1').attributes.merge(pools: pools.collect(&:id)).with_indifferent_access] }

      let(:well_factory) do
        build(:pacbio_well_factory, plate:, well_attributes:)
      end

      it 'does not return any #new_wells attributes' do
        expect(well_factory.new_wells).to eq([])
      end

      it 'returns existing well attributes on #existing_wells' do
        expect(well_factory.existing_wells).to eq(well_factory.well_attributes)
      end
    end

    # create an well_factory with new wells
    context.skip 'well factory with new wells' do
      let!(:wells) { [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'B', column: '1')] }
      let(:run) { create(:pacbio_run, plates: [create(:pacbio_plate, wells:)]) }
      let!(:pool) { create(:pacbio_pool) }
      let!(:plate) { create(:pacbio_plate) }

      it 'returns #new_well attributes' do
        well_attributes = run.plates.first.wells.collect { |well| well.attributes.with_indifferent_access }
        well_attributes.first.merge!(pools: [pool.id])
        well_factory = build(:pacbio_well_factory, plate:, well_attributes:)
        expect(well_factory.new_wells).to eq(well_factory.well_attributes)
      end

      it 'does not return any #existing_wells attributes' do
        well_attributes = run.plates.first.wells.collect { |well| well.attributes.with_indifferent_access }
        well_attributes.first.merge!(pools: [pool.id])
        well_factory = build(:pacbio_well_factory, plate:, well_attributes:)
        expect(well_factory.existing_wells).to eq([])
      end
    end
  end
end
