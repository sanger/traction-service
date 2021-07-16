# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::WellFactory, type: :model, pacbio: true do

  let(:plate)           { create(:pacbio_plate) }
  let(:pools)           { create_list(:pacbio_pool, 3) }
  let(:wells_attributes) {
                          [
                            attributes_for(:pacbio_well).except(:plate).merge(
                              plate: {type: 'plate', id: plate.id},
                              pools: [{type: 'pools', id: pools[0].id}]),
                            attributes_for(:pacbio_well).except(:plate).merge(
                              plate: {type: 'plate', id: plate.id},
                              pools: [{type: 'pools', id: pools[1].id}]),
                            attributes_for(:pacbio_well).except(:plate).merge(
                              plate: {type: 'plate', id: plate.id},
                              pools: [{type: 'pools', id: pools[2].id}])
                        ]}

  context 'WellFactory' do
    context '#initialize' do
      it 'creates a list of WellFactory::Wells' do
        factory = Pacbio::WellFactory.new(wells_attributes)
        expect(factory.wells.count).to eq(3)
        expect(factory.wells[0].class).to eq Pacbio::WellFactory::Well
        expect(factory.wells[1].class).to eq Pacbio::WellFactory::Well
        expect(factory.wells[2].class).to eq Pacbio::WellFactory::Well
      end

      it 'creates a well for each WellFactory::Well' do
        factory = Pacbio::WellFactory.new(wells_attributes)
        expect(factory.wells[0].well).to be_present
        expect(factory.wells[1].well).to be_present
        expect(factory.wells[2].well).to be_present
      end
    end

    context '#plate' do
      it 'sets the default plate of the wells' do
        factory = Pacbio::WellFactory.new(wells_attributes)
        expect(factory.plate.id).to eq(wells_attributes[0][:plate][:id])
      end
    end

    context '#save' do
      it 'will save the wells if they are valid' do
        factory = Pacbio::WellFactory.new(wells_attributes)
        expect(factory).to be_valid
        expect(factory.save).to be_truthy
      end

      it 'will call the WellFactory:Well save if wells are valid' do
        factory = Pacbio::WellFactory.new(wells_attributes)

        expect(factory.wells[0]).to receive(:save)
        expect(factory.wells[1]).to receive(:save)
        expect(factory.wells[2]).to receive(:save)

        factory.save
      end

      it 'will not save the wells if they are not valid' do
        factory = Pacbio::WellFactory.new([])
        expect(factory).to_not be_valid
        expect(factory.save).to be_falsey
        expect(factory.errors.messages[:wells]).to eq ['there are no wells']
      end
    end

    context '#errors' do
      context 'when the error is the in WellFactory' do
        it 'returns the correct error message' do
          factory = Pacbio::WellFactory.new([])
          factory.save
          expect(factory.errors.messages[:wells]).to eq ['there are no wells']
        end
      end

      context 'when the error is the in WellFactory:Well' do
        let(:wells_attributes_well_error)  {
                                  [ attributes_for(:pacbio_well).except(:movie_time).except(:plate).merge( plate: {type: 'plate', id: plate.id}, pools: [{type: 'pools', id: pools.first.id}]) ]
                                }

        it 'returns the correct error message' do
          factory = Pacbio::WellFactory.new(wells_attributes_well_error)
          factory.save
          expect(factory.errors.messages[:movie_time]).to eq ["can't be blank", "is not a number"]
        end
      end
    end
  end

  context 'WellFactory::Well' do
    let(:pool1)             { create(:pacbio_pool) }
    let(:pool2)             { create(:pacbio_pool) }
    let(:pool_attributes)               { [
                                          { type: 'pools', id: pool1.id },
                                          { type: 'pools', id: pool2.id }
                                        ] }
    let(:well_attributes)               { attributes_for(:pacbio_well).except(:plate).merge(
                                          plate: { type: 'plate', id: plate.id },
                                          pools: pool_attributes)
                                        }

    context '#initialize' do
      context 'when the wells dont exist' do

        it 'builds the Pacbio::Well' do
          factory = Pacbio::WellFactory::Well.new(well_attributes)
          expect(factory.well.class).to eq Pacbio::Well
          expect(factory.well.id).to eq nil
          expect(factory.well.movie_time).to eq well_attributes[:movie_time]
          expect(factory.well.insert_size).to eq well_attributes[:insert_size].to_i
          expect(factory.well.on_plate_loading_concentration).to eq well_attributes[:on_plate_loading_concentration].to_f
          expect(factory.well.row).to eq well_attributes[:row]
          expect(factory.well.column).to eq well_attributes[:column]
          expect(factory.well.comment).to eq well_attributes[:comment]
        end

        it 'creates a list of WellFactory::Well::Pools' do
          factory = Pacbio::WellFactory::Well.new(well_attributes)
          expect(factory.pools.class).to eq Pacbio::WellFactory::Well::Pools
          expect(factory.pools.pools.length).to eq(2)
        end

        it 'sets the Pacbio::Well plate' do
          factory = Pacbio::WellFactory::Well.new(well_attributes)
          expect(factory.well.plate).to eq plate
        end

        it 'produces an error message if the plate doesnt exist' do
          well_attributes_no_plate = attributes_for(:pacbio_well).except(:plate).merge( pools: [{type: 'pools', id: pools.last.id}] )
          factory = Pacbio::WellFactory::Well.new(well_attributes_no_plate)
          expect(factory).to_not be_valid
          expect(factory.errors.full_messages).to include 'Plate must exist'
        end

        it 'creates the well with no pools, when pools arent included' do
          well_with_no_pools = well_attributes.except(:pools)
          factory = Pacbio::WellFactory::Well.new(well_with_no_pools)

          expect(factory.well.id).to eq nil
          expect(factory.well.pools.length).to eq(0)
        end
      end

      context 'when the wells do exist' do
        let(:well_with_pools)     { create(:pacbio_well_with_pools) }
        let(:pool1)               { create(:pacbio_pool) }
        let(:pool2)               { create(:pacbio_pool) }
        let(:updated_well_attributes)  { { id: well_with_pools.id, insert_size: 123, on_plate_loading_concentration: 12,
                                           pools: [ { type: 'pools', id: pool1.id }, { type: 'pools', id: pool2.id } ]
                                       } }

        it 'updates the Pacbio::Well' do
          factory = Pacbio::WellFactory::Well.new(updated_well_attributes)
          expect(factory.well.id).to eq well_with_pools.id
          expect(factory.well.movie_time).to eq well_with_pools[:movie_time]
          expect(factory.well.insert_size).to eq updated_well_attributes[:insert_size].to_i
          expect(factory.well.on_plate_loading_concentration).to eq updated_well_attributes[:on_plate_loading_concentration].to_f
          expect(factory.well.row).to eq well_with_pools[:row]
          expect(factory.well.column).to eq well_with_pools[:column]
          expect(factory.well.comment).to eq well_with_pools[:comment]
        end

        it 'creates a list of WellFactory::Well::Pools' do
          factory = Pacbio::WellFactory::Well.new(updated_well_attributes)
          expect(factory.pools.class).to eq Pacbio::WellFactory::Well::Pools
          expect(factory.pools.pools.length).to eq(2)
          expect(factory.pools.pools[0].id).to eq pool1.id
          expect(factory.pools.pools[1].id).to eq pool2.id
        end
      end
    end

    context '#save' do
      it 'creates the wells, if each well is valid' do
        factory = Pacbio::WellFactory::Well.new(well_attributes)
        expect(factory).to be_valid
        expect { factory.save }.to change(Pacbio::Well, :count).by(1)
      end

      it 'will call the WellFactory:Well::Pools save if wells are valid' do
        factory = Pacbio::WellFactory::Well.new(well_attributes)
        expect(factory.pools).to receive(:save)

        factory.save
      end

      it 'wont create the wells, if any well is invalid' do
        well_attributes_no_movie_time = well_attributes.except(:movie_time)
        factory = Pacbio::WellFactory::Well.new(well_attributes_no_movie_time)
        expect(factory).to_not be_valid
        expect { factory.save }.to change(Pacbio::Well, :count).by(0)
        expect(factory.errors.messages[:movie_time]).to eq ["can't be blank", "is not a number"]
      end
    end

    context '#pools' do
      it 'creates a list of WellFactory::Well::Pools' do
        factory = Pacbio::WellFactory::Well.new(well_attributes)
        expect(factory.pools.class).to eq Pacbio::WellFactory::Well::Pools
        expect(factory.pools.pools.length).to eq(2)
      end
    end

    context '#id' do
      it 'returns the Pacbio::Well id' do
        factory = Pacbio::WellFactory::Well.new(well_attributes)
        factory.save
        expect(factory.id).to eq Pacbio::Well.last.id
      end
    end
  end

  context 'WellFactory::Well::Pools' do
    let(:well)                       { create(:pacbio_well) }
    let(:pool1)                      { create(:pacbio_pool) }
    let(:pool2)                      { create(:pacbio_pool) }
    let(:pool_attributes)            { [
                                          { type: 'pools', id: pool1.id },
                                          { type: 'pools', id: pool2.id }
                                       ] }

    context '#initialize' do
      it 'creates a list of Pacbio::Pool' do
        factory = Pacbio::WellFactory::Well::Pools.new(well, pool_attributes)
        expect(factory.pools.count).to eq(pool_attributes.length)
        expect(factory.pools[0].class).to eq Pacbio::Pool
        expect(factory.pools[1].class).to eq Pacbio::Pool
      end
    end

    context '#pools' do
      it 'contains a list of Pacbio::Pool' do
        factory = Pacbio::WellFactory::Well::Pools.new(well, pool_attributes)
        expect(factory.pools.count).to eq(pool_attributes.length)
      end
    end

    context '#well' do
      it 'contains the given Pacbio::Pool' do
        factory = Pacbio::WellFactory::Well::Pools.new(well, pool_attributes)
        expect(factory.well).to eq(well)
      end
    end

    context '#save' do
      it 'updates the wells pools, if pools are valid' do
        factory = Pacbio::WellFactory::Well::Pools.new(well, pool_attributes)
        expect(factory).to be_valid
        expect(factory.save).to be_truthy
        expect(well.pools.length).to eq pool_attributes.length
        expect(well.pools[0].id).to eq pool_attributes[0][:id]
        expect(well.pools[1].id).to eq pool_attributes[1][:id]
      end
    end
  end
end
