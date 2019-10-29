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
    it 'creates an object for each given well' do
      factory = Pacbio::WellFactory.new(wells_attributes)
      expect(factory.wells.count).to eq(3)

      well = factory.wells.first
      expect(well.plate).to eq(plate)
      expect(well.libraries.length).to eq(1)
    end

    it 'produces error messages if any of the wells are not valid' do
      wells_attributes << attributes_for(:pacbio_well).except(:plate)
      factory = Pacbio::WellFactory.new(wells_attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
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
