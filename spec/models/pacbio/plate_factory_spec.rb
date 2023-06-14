# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::PlateFactory do
  before do
    # Create a default pacbio smrt link version for pacbio runs.
    create(:pacbio_smrt_link_version, name: 'v11', default: true)
  end

  let!(:run) { create(:pacbio_run) }

  describe '#construct_resources!' do
    subject(:construct_resources) do
      plate_factory.construct_resources!
    end

    let(:plate_factory) do
      build(:pacbio_plate_factory, run:, well_attributes:)
    end

    context 'create' do
      let!(:pools) { [create(:pacbio_pool), create(:pacbio_pool)] }
      let(:well_attributes) { [attributes_for(:pacbio_well).except(:plate, :pools, :run).merge(pools: pools.collect(&:id)).with_indifferent_access] }

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

    context 'update wells' do
      let!(:wells) { [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'B', column: '1')] }
      let!(:run) { create(:pacbio_run, plates: [create(:pacbio_plate, wells:)]) }
      let!(:pool) { create(:pacbio_pool) }

      it 'updates existing wells' do
        well_attributes = run.plates.first.wells.collect { |well| well.attributes.with_indifferent_access.merge(pools: well.pools.pluck(:id)) }
        well_attributes.first.merge!(pools: [pool.id])
        plate_factory = build(:pacbio_plate_factory, run:, well_attributes:)
        plate_factory.construct_resources!
        run.reload
        expect(run.plates.first.wells.find_by(row: 'A', column: '1').pools).to eq([pool])
      end

      it 'creates new wells', skip: "Need to set well pool to have well optional" do
        well_attributes = run.plates.first.wells.collect { |well| well.attributes.with_indifferent_access.merge(pools: well.pools.pluck(:id)) }
        well_attributes << build(:pacbio_well, row: 'C', column: '1').attributes.with_indifferent_access.merge(pools: [pool.id])
        plate_factory = build(:pacbio_plate_factory, run:, well_attributes:)
        plate_factory.construct_resources!
        run.reload
        expect(run.plates.first.wells.count).to eq(3)
      end

      it 'deletes wells that are no longer exist' do
        well_attributes = run.plates.first.wells.collect { |well| well.attributes.with_indifferent_access.merge(pools: well.pools.pluck(:id)) }
        well_attributes.pop
        plate_factory = build(:pacbio_plate_factory, run:, well_attributes:)
        plate_factory.construct_resources!
        run.reload
        expect(run.plates.first.wells.count).to eq(1)
      end
    end
  end

  describe 'with invalid well' do
    subject(:plate_factory) { build(:pacbio_plate_factory, run:, well_attributes:) }

    let(:well_attributes) { [attributes_for(:pacbio_well).except(:plate, :pools, :run).merge(row: nil)] }

    it { is_expected.to be_invalid }
  end
end
