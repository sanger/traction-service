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
    context 'when the wells dont exist' do
      it 'creates an object for each given well' do
        factory = Pacbio::WellFactory.new(wells_attributes)
        expect(factory.wells.count).to eq(3)

        # well1 = factory.wells[0]
        # well2 = factory.wells[1]
        # well3 = factory.wells[2]
        # expect(well1.plate).to eq(plate)
        # expect(well2.plate).to eq(plate)
        # expect(well3.plate).to eq(plate)

        # expect(well1.libraries.length).to eq(1)
        # expect(well2.libraries.length).to eq(1)
        # expect(well3.libraries.length).to eq(1)
      end

      it 'sets the plate of each given well' do
        factory = Pacbio::WellFactory.new(wells_attributes)

        expect(factory.plate).to eq(plate)
        expect(factory.wells[0].plate).to eq(plate)
        expect(factory.wells[1].plate).to eq(plate)
        expect(factory.wells[2].plate).to eq(plate)
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

      context 'when there are multiple libraries' do
        let(:libraries_16)       { create_list(:pacbio_library, 16) }
        let(:libraries_17)       { create_list(:pacbio_library, 17) }

        it 'creates the well with multiple libraries, when there are up to 16 libraries' do
          wells_attributes.map { |well| well[:libraries] = libraries_16.map { |l| { type: "libraries", id: l.id } } }
          factory = Pacbio::WellFactory.new(wells_attributes)

          expect(factory.wells[0].libraries.length).to eq(16)
          expect(factory.wells[1].libraries.length).to eq(16)
          expect(factory.wells[2].libraries.length).to eq(16)
        end

        it 'does not create the well with multiple libraries, when there are more than 16 libraries' do
          wells_attributes.map { |well| well[:libraries] = libraries_17.map { |l| { type: "libraries", id: l.id } } }
          factory = Pacbio::WellFactory.new(wells_attributes)
          expect(factory.wells[0].libraries.length).to eq(0)
          expect(factory.wells[1].libraries.length).to eq(0)
          expect(factory.wells[2].libraries.length).to eq(0)

          expect(factory.errors.messages[:libraries][0][:libraries]).to include 'There are more than 16 libraries in well ' + factory.wells[0].position
          expect(factory.errors.messages[:libraries][1][:libraries]).to include 'There are more than 16 libraries in well ' + factory.wells[1].position
          expect(factory.errors.messages[:libraries][2][:libraries]).to include 'There are more than 16 libraries in well ' + factory.wells[2].position
        end

        it 'only creates the well libraries, for wells with 16 or less libraries' do
          wells_attributes[0][:libraries] = libraries_17.map { |l| { type: "libraries", id: l.id } }
          factory = Pacbio::WellFactory.new(wells_attributes)
          expect(factory.wells[0].libraries.length).to eq(0)
          expect(factory.wells[1].libraries.length).to eq(1)
          expect(factory.wells[2].libraries.length).to eq(1)

          expect(factory.errors.messages[:libraries][0][:libraries]).to include 'There are more than 16 libraries in well ' + factory.wells[0].position
        end
      end
    end

    context 'when the wells do exist' do
      let(:well_with_libraries)                { create(:pacbio_well_with_libraries) }
      let(:new_library1) { create(:pacbio_library) }
      let(:new_library2) { create(:pacbio_library) }
      let(:updated_wells_attributes) {
        [ id: well_with_libraries.id, insert_size: 123, on_plate_loading_concentration: 12, libraries: [ { type: 'libraries', id: new_library1.id }, { type: 'libraries', id: new_library2.id } ] ]
      }

      it 'updates the well, if the well id exists' do
        factory = Pacbio::WellFactory.new(updated_wells_attributes)
        expect(factory.wells.count).to eq(1)
        well = factory.wells.first

        expect(well.insert_size).to eq(123)
        expect(well.on_plate_loading_concentration).to eq(12)
      end

      it 'updates the wells libraries, when libraries are present' do
        factory = Pacbio::WellFactory.new(updated_wells_attributes)
        expect(factory.wells.count).to eq(1)
        well = factory.wells.first
        expect(well.libraries.length).to eq(updated_wells_attributes.first[:libraries].length)
        expect(well.libraries[0].id).to eq(new_library1.id)
        expect(well.libraries[1].id).to eq(new_library2.id)
      end

      it 'does not update the wells libraries, when libraries are not present' do
        factory = Pacbio::WellFactory.new([updated_wells_attributes[0].except(:libraries)])
        expect(factory.wells.count).to eq(1)
        well = factory.wells.first
        expect(well.libraries.length).to eq(well_with_libraries.libraries.length)
      end

      it 'has a plate' do
        factory = Pacbio::WellFactory.new(updated_wells_attributes)
        expect(factory.plate).to eq well_with_libraries.plate
      end
    end

  end

  context '#save' do
    it 'creates the wells, if each well is valid' do
      factory = Pacbio::WellFactory.new(wells_attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(Pacbio::Well.count).to eq(3)
      expect(Pacbio::Well.all[0].libraries.count).to eq(1)
      expect(Pacbio::Well.all[1].libraries.count).to eq(1)
      expect(Pacbio::Well.all[2].libraries.count).to eq(1)
    end

    it 'wont create the wells, if any well is invalid ' do
      wells_attributes << attributes_for(:pacbio_well).except(:plate)
      factory = Pacbio::WellFactory.new(wells_attributes)
      expect(factory).to_not be_valid
      expect(factory.save).to be_falsey
      expect(factory.errors.full_messages).to include "Plate must exist"
      expect(Pacbio::Well.count).to eq(0)
    end

    it 'wont create the wells , if wells are empty' do
      factory = Pacbio::WellFactory.new([])
      expect(factory).to_not be_valid
      expect(factory.save).to be_falsey
      expect(factory.errors.full_messages).to include "Wells there are no wells"
      expect(Pacbio::Well.count).to eq(0)
    end
  end

end
