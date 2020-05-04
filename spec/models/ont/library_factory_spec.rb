require 'rails_helper'

RSpec.describe Ont::PlateFactory, type: :model, ont: true do
  let!(:plate) { create(:plate_with_wells, row_count: 3, column_count: 3) }
  let!(:tag_set) { create(:tag_set_with_tags, number_of_tags: 9) }
  let!(:well_primary_grouping_direction) { 'column' }

  context '#initialise' do
    it 'is invalid if given no plate_barcode' do
      attributes = { 
        tag_set_name: tag_set.name,
        well_primary_grouping_direction: well_primary_grouping_direction
      }
      factory = Ont::LibraryFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

    it 'is invalid if plate does not exist' do
      attributes = {
        plate_barcode: 'does not exist',
        tag_set_name: tag_set.name,
        well_primary_grouping_direction: well_primary_grouping_direction
      }
      factory = Ont::LibraryFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

    it 'is invalid if given no tag_set_name' do
      attributes = {
        plate_barcode: 'does not exist',
        well_primary_grouping_direction: well_primary_grouping_direction
      }
      factory = Ont::LibraryFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

    it 'is invalid if tag set does not exist' do
      attributes = {
        plate_barcode: plate.barcode,
        tag_set_name: 'does not exist',
        well_primary_grouping_direction: well_primary_grouping_direction
      }
      factory = Ont::LibraryFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

    it 'is invalid if number of tags is not a factor of number of wells' do
      attributes = {
        plate_barcode: plate.barcode,
        tag_set_name: create(:tag_set_with_tags, number_of_tags: 4),
        well_primary_grouping_direction: well_primary_grouping_direction
      }
      factory = Ont::LibraryFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

    it 'is invalid if given no well_primary_grouping_direction' do
      attributes = {
        plate_barcode: plate.barcode,
        tag_set_name: tag_set.name,
      }
      factory = Ont::LibraryFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

    it 'is invalid if given unknown well_primary_grouping_direction' do
      attributes = {
        plate_barcode: plate.barcode,
        tag_set_name: tag_set.name,
        well_primary_grouping_direction: 'invalid direction'
      }
      factory = Ont::LibraryFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end
  end

  context '#save' do
    context 'valid build' do
      context 'with one tag set iteration' do
        # tags requests according to the primary grouping direction (creates tag taggables)
        # creates a new library with those requests
        # create a new tube for the library
        # creates a container material for the tube and library
      end

      context 'with many tag set iterations' do
        # tags requests according to the primary grouping direction (creates tag taggables)
        # creates new libraries with the correct requests
        # create a new tube for each library
        # creates a container material for each new tube and library
      end
    end

    context 'invalid build' do
      it 'is invalid' do
        factory = Ont::LibraryFactory.new({})
        expect(factory).to_not be_valid
      end

      it 'returns false on save' do
        factory = Ont::LibraryFactory.new({})
        expect(factory.save).to be_falsey
      end

      it 'does not create any tag taggables' do
        factory = Ont::LibraryFactory.new({})
        factory.save
        expect(::TagTaggable.all.count).to eq(0)
      end
  
      it 'does not create any libraries' do
        factory = Ont::LibraryFactory.new({})
        factory.save
        expect(Ont::Library.all.count).to eq(0)
      end

      it 'does not create any tubes' do
        factory = Ont::LibraryFactory.new({})
        factory.save
        expect(::Tube.all.count).to eq(0)
      end

      it 'does not create any container materials' do
        factory = Ont::LibraryFactory.new({})
        factory.save
        expect(::ContainerMaterial.all.count).to eq(0)
      end
    end
  end
end
