# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::WellFactory, type: :model, pacbio: true do

  let(:plate)           { create(:pacbio_plate) }
  let(:libraries)       { create_list(:pacbio_library, 3) }
  let(:wells_attributes) { 
                          [
                            attributes_for(:pacbio_well).except(:plate).merge( plate: {type: 'plate', id: plate.id}, libraries: [{type: 'libraries', id: libraries.first.id}]),
                            attributes_for(:pacbio_well).except(:plate).merge( plate: {type: 'plate', id: plate.id}, libraries: [{type: 'libraries', id: libraries[1].id}]),
                            attributes_for(:pacbio_well).except(:plate).merge( plate: {type: 'plate', id: plate.id}, libraries: [{type: 'libraries', id: libraries.last.id}])
                        ]}

  context '#initialize' do
    context '#create - when the wells dont exist' do
      it 'creates an object for each given well' do
        factory = Pacbio::WellFactory.new(wells_attributes)
        factory.save

        expect(factory.wells.count).to eq(3)

        well1 = factory.wells[0]
        well2 = factory.wells[1]
        well3 = factory.wells[2]
        expect(well1.plate).to eq(plate)
        expect(well2.plate).to eq(plate)
        expect(well3.plate).to eq(plate)

        expect(well1.libraries.length).to eq(1)
        expect(well2.libraries.length).to eq(1)
        expect(well3.libraries.length).to eq(1)
      end

      it 'has a plate' do
        factory = Pacbio::WellFactory.new(wells_attributes)
        expect(factory.plate).to eq(plate)
      end

      it 'produces an error message if the plate doesnt exist' do
        wells_attributes << attributes_for(:pacbio_well).except(:plate).merge( libraries: [{type: 'libraries', id: libraries.last.id}])
        factory = Pacbio::WellFactory.new(wells_attributes)
        expect(factory).to_not be_valid
        expect(factory.errors.full_messages).to include 'Plate must exist'
      end

      it 'creates the well with no libraries, when libraries arent included' do
        wells_with_no_libraries = wells_attributes.map { |well| well.except(:libraries) }
        factory = Pacbio::WellFactory.new(wells_with_no_libraries)

        well = factory.wells[0]
        expect(well.libraries.length).to eq(0)
      end

      it 'creates the well with no libraries, if the given libraries dont exist' do
        wells_attributes.map { |well| well[:libraries][0][:id] = 123 } 
        factory = Pacbio::WellFactory.new(wells_attributes)

        well = factory.wells[0]
        expect(well.libraries.length).to eq(0)
      end

      it 'creates the well with multiple libraries, when there are multiple libraries per well' do
        new_library = create(:pacbio_library)
        wells_attributes.map { |well| well[:libraries] << { type: 'libraries', id: new_library.id }}        
        factory = Pacbio::WellFactory.new(wells_attributes)
        
        expect(factory.wells[0].libraries.length).to eq(2)
        expect(factory.wells[1].libraries.length).to eq(2)
        expect(factory.wells[2].libraries.length).to eq(2)
      end
    end

    context '#update - when the wells do exist' do
      let(:well_with_libraries)                { create(:pacbio_well_with_libraries) }
      let(:new_library1) { create(:pacbio_library) }
      let(:new_library2) { create(:pacbio_library) }
      let(:updated_wells_attributes) {
        [ id: well_with_libraries.id, insert_size: 123, on_plate_loading_concentration: 12, libraries: [ { type: 'libraries', id: new_library1.id }, { type: 'libraries', id: new_library2.id } ] ]
      }

      it 'updates the well' do
        factory = Pacbio::WellFactory.new(updated_wells_attributes)
        expect(factory.wells.count).to eq(1)
        well = factory.wells.first

        expect(well.insert_size).to eq(123)
        expect(well.on_plate_loading_concentration).to eq(12)
      end

      it 'updates the wells libraries' do
        factory = Pacbio::WellFactory.new(updated_wells_attributes)
        expect(factory.wells.count).to eq(1)
        well = factory.wells.first
        expect(well.libraries.length).to eq(updated_wells_attributes.first[:libraries].length)
        expect(well.libraries[0].id).to eq(new_library1.id)
        expect(well.libraries[1].id).to eq(new_library2.id)
      end

      it 'has a plate' do
        factory = Pacbio::WellFactory.new(updated_wells_attributes)
        expect(factory.plate).to be_present
      end
    end

  end

  context '#save' do
    it 'if valid creates the wells' do
      factory = Pacbio::WellFactory.new(wells_attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(Pacbio::Well.count).to eq(3)
      expect(Pacbio::Well.first.libraries.count).to eq(1)
    end

    it 'if invalid wont create the wells' do
      wells_attributes << attributes_for(:pacbio_well).except(:plate)
      factory = Pacbio::WellFactory.new(wells_attributes)
      expect(factory).to_not be_valid
      expect(factory.save).to be_falsey
      expect(Pacbio::Well.count).to eq(0)
    end

  end

end
