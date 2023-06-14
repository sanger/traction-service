# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::WellFactory do
  before do
    # Create a default pacbio smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v11', default: true)
  end

  describe '#construct_resources' do
    subject(:construct_resources) do
      well_factory.construct_resources!
    end

    describe '#create' do
      let(:well_factory) do
        build(:pacbio_well_factory, plate:, well_attributes:)
      end

      let!(:plate) { build(:pacbio_plate, well_count: 0) }
      let!(:pools) { create_list(:pacbio_pool, 2) }
      let(:well_attributes) { [build(:pacbio_well, row: 'A', column: '1').attributes.merge(pools: pools.collect(&:id)).with_indifferent_access] }

      context 'valid' do
        let(:well_factory) do
          build(:pacbio_well_factory, plate:, well_attributes:)
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

      context 'invalid' do
        it 'when the well is not valid' do
          well_attributes << build(:pacbio_well, row: nil, column: '1').attributes.merge(pools: pools.collect(&:id)).with_indifferent_access
          well_factory = build(:pacbio_well_factory, plate:, well_attributes:)
          expect(well_factory).not_to be_valid
        end

        it 'does not create wells with invalid well positions', skip: 'Not sure we can do this here as this validation is run level' do
          well_attributes << build(:pacbio_well, row: 'F', column: '1').attributes.merge(pools: pools.collect(&:id)).with_indifferent_access
          well_factory = build(:pacbio_well_factory, plate:, well_attributes:)
          expect(well_factory).not_to be_valid
        end

        it 'does not create wells with invalid well contiguousness', skip: 'Not sure we can do this here as this validation is run level' do
          well_attributes << build(:pacbio_well, row: 'C', column: '1').attributes.merge(pools: pools.collect(&:id)).with_indifferent_access
          well_factory = build(:pacbio_well_factory, plate:, well_attributes:)
          expect(well_factory).not_to be_valid
        end
      end
    end

    describe '#update' do
      let!(:wells) { [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'B', column: '1')] }
      let(:run) { create(:pacbio_run, plates: [create(:pacbio_plate, wells:)]) }
      let!(:pool) { create(:pacbio_pool) }

      it 'updates existing wells' do
        well_attributes = run.plates.first.wells.collect { |well| well.attributes.merge(pools: well.pools.pluck(:id)).with_indifferent_access }
        well_attributes.first.merge!(pools: [pool.id])
        well_factory = build(:pacbio_well_factory, plate: run.plates.first, well_attributes:)
        well_factory.construct_resources!
        run.reload
        expect(run.plates.first.wells.find_by(row: 'A', column: '1').pools).to eq([pool])
      end

      # further investigation here:
      #  - it looks like it is trying to validate the well pool because the well and pool must both exist
      #  - but the well in the well pool does not exist until after the well is created
      #  - this means that the failure is circular. We don't actually want to create the well pool until the well is saved
      #  - but the well needs to have pools hence failure.
      it 'adds new wells', skip: 'test is not currently working because well pools and pools are invalid' do
        well_attributes = run.plates.first.wells.collect { |well| well.attributes.merge(pools: well.pools.pluck(:id)).with_indifferent_access }
        well_attributes << build(:pacbio_well, row: 'C', column: '1').attributes.merge(pools: [pool.id]).with_indifferent_access
        well_factory = build(:pacbio_well_factory, plate: run.plates.first, well_attributes:)
        well_factory.construct_resources!
        run.reload
        expect(run.plates.first.wells.count).to eq(3)
        # we need to check the pools. Due to the issue with well pools
        expect(run.plates.first.wells.last.pools).to eq([pool])
      end

      it 'deletes wells that no longer exist' do
        well_attributes = run.plates.first.wells.collect { |well| well.attributes.with_indifferent_access.merge(pools: well.pools.pluck(:id)) }
        well_attributes.pop
        well_factory = build(:pacbio_well_factory, plate: run.plates.first, well_attributes:)
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
    context 'well factory with new wells' do
      let!(:wells) { [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'B', column: '1')] }
      let(:run) { create(:pacbio_run, plates: [create(:pacbio_plate, wells:)]) }
      let!(:pool) { create(:pacbio_pool) }

      it 'returns #new_well attributes' do
        well_attributes = run.plates.first.wells.collect { |well| well.attributes.with_indifferent_access }
        well_attributes.first.merge!(pools: [pool.id])
        well_factory = build(:pacbio_well_factory, plate: run.plates.first, well_attributes:)
        expect(well_factory.new_wells).to eq(well_factory.well_attributes)
      end

      it 'does not return any #existing_wells attributes' do
        well_attributes = run.plates.first.wells.collect { |well| well.attributes.with_indifferent_access }
        well_attributes.first.merge!(pools: [pool.id])
        well_factory = build(:pacbio_well_factory, plate: run.plates.first, well_attributes:)
        expect(well_factory.existing_wells).to eq([])
      end
    end
  end
end
