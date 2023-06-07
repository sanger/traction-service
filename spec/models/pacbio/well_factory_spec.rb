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

    let(:well_factory) do
      build(:pacbio_well_factory, well_attributes:)
    end

    context '#create' do
      let!(:pools) { [create(:pacbio_pool), create(:pacbio_pool)] }
      let(:well_attributes) { [attributes_for(:pacbio_well)] }

      it 'creates a well' do
        well_factory.well_attributes = [build(:pacbio_well, row: 'A', column: '1')]
        expect(well_factory).to be_valid
        expect { well_factory.construct_resources }.to change(Pacbio::Well, :count).by(1)
      end

      it 'attaches pools to the well' do
        construct_resources
        expect(Pacbio::Well.first.pools.count).to eq(pools.length)
        expect(Pacbio::Well.first.pools.first).to eq(pools.first)
        expect(Pacbio::Well.first.pools.last).to eq(pools.last)
      end
    end

    context '#update' do
      let!(:wells) { [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'B', column: '1')] }
      let!(:run) { create(:pacbio_run, plates: [create(:pacbio_plate, wells:)])}
      let!(:pool) { create(:pacbio_pool)}

      # before do 
      #   well_factory.wells << wells
      # end

      it 'updates existing wells' do
        # receive the well attributes
        well_attributes = run.plates.first.wells.collect { |well| well.attributes }
        # modify the attributes
        well_attributes.first.merge!(pools: [pool.id])
        well_factory = build(:pacbio_well_factory, well_attributes: well_attributes)
        well_factory.construct_resources!
        run.reload
        expect(run.plates.first.wells.count).to eq(3)
      end

      it 'deletes wells that no longer exist' do
        # Add test case logic
      end
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

  describe '#new_wells' do
    it 'returns an empty array when there are no new wells' do
      expect(well_factory.new_wells).to eq([])
    end

    it 'returns an array of well attributes belonging to the new wells' do
      # populate the well factory with wells
      well_factory.well_attributes = [build(:pacbio_well, row: 'A', column: '1'), build(:pacbio_well, row: 'B', column: '1')]
      # should return the attributes of the two wells built
      expect(well_factory.new_wells).to eq([{}])
    end
  end

  describe '#existing_wells' do
    it 'returns an empty array when all wells are new' do
      expect(well_factory.existing_wells).to eq([])
    end

    it 'returns an array of well attributes belonging to existing wells' do
      # Add test case logic
    end
  end
end
