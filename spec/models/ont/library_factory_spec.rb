require 'rails_helper'

RSpec.describe Ont::LibraryFactory, type: :model, ont: true do
  let!(:plate) { create(:plate_with_tagged_ont_requests, row_count: 3, column_count: 3) }

  context '#initialise' do
    it 'is invalid if given no plate_barcode' do
      factory = Ont::LibraryFactory.new({})
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

    it 'is invalid if plate does not exist' do
      attributes = { plate_barcode: 'does not exist' }
      factory = Ont::LibraryFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end

    it 'is invalid if requests are not uniquely tagged' do
      tag = create(:tag)
      allow_any_instance_of(Ont::Request).to receive(:sorted_tags).and_return([tag])
      attributes = { plate_barcode: plate.barcode }
      factory = Ont::LibraryFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end
  end

  context '#save' do
    context 'valid build' do
      let!(:attributes) { { plate_barcode: plate.barcode } }

      it 'creates expected library with empty wells' do
        barcode = 'empty plate barcode'
        empty_plate = create(:plate_with_wells, barcode: barcode, row_count: 3, column_count: 3)
        factory = Ont::LibraryFactory.new({ plate_barcode: barcode })
        factory.save
        expect(Ont::Library.count).to eq(1)
        expect(Ont::Library.first.name).to eq("#{barcode}-1")
        expect(Ont::Library.first.pool).to eq(1)
        expect(Ont::Library.first.pool_size).to eq(9)
        expect(Ont::Library.first.requests).to be_empty
      end

      it 'creates expected library with filled wells' do
        factory = Ont::LibraryFactory.new(attributes)
        factory.save
        expect(Ont::Library.count).to eq(1)
        expect(Ont::Library.first.name).to eq("#{plate.barcode}-1")
        expect(Ont::Library.first.pool).to eq(1)
        expect(Ont::Library.first.pool_size).to eq(9)
        expect(Ont::Library.first.requests).to match_array(Ont::Request.all)
      end

      it 'creates and exposes a tube that contains the library' do
        factory = Ont::LibraryFactory.new(attributes)
        factory.save
        expect(Tube.count).to eq(1)
        expect(factory.tube).to eq(Tube.first)
        expect(Tube.first.materials.count).to eq(1)
        expect(Tube.first.materials).to contain_exactly(Ont::Library.first)
      end

      context 'validates' do
        let!(:library) { create(:ont_library) }
        let!(:tube) { create(:tube) }
        let!(:container_material) { create(:container_material) }

        it 'each library exactly once' do
          allow(Ont::Library).to receive(:new).and_return(library)
          expect(library).to receive(:valid?).exactly(1)
          factory = Ont::LibraryFactory.new(attributes)
          factory.save
        end

        it 'each tube exactly once' do
          allow(Tube).to receive(:new).and_return(tube)
          expect(tube).to receive(:valid?).exactly(1)
          factory = Ont::LibraryFactory.new(attributes)
          factory.save
        end

        it 'each tube container_material exactly once' do
          allow(ContainerMaterial).to receive(:new).and_return(container_material)
          expect(container_material).to receive(:valid?).exactly(1)
          factory = Ont::LibraryFactory.new(attributes)
          factory.save
        end
      end

      context 'without validation' do
        let!(:library) { create(:ont_library) }
        let!(:tube) { create(:tube) }
        let!(:container_material) { create(:container_material) }

        it 'does not validate created libraries' do
          allow(Ont::Library).to receive(:new).and_return(library)
          expect(library).to_not receive(:valid?)
          factory = Ont::LibraryFactory.new(attributes)
          factory.save(validate: false)
        end

        it 'does not validate created tubes' do
          allow(Tube).to receive(:new).and_return(tube)
          expect(tube).to_not receive(:valid?)
          factory = Ont::LibraryFactory.new(attributes)
          factory.save(validate: false)
        end

        it 'does not validate created container materials' do
          allow(ContainerMaterial).to receive(:new).and_return(container_material)
          expect(container_material).to_not receive(:valid?)
          factory = Ont::LibraryFactory.new(attributes)
          factory.save(validate: false)
        end
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
  
      it 'does not create any libraries' do
        factory = Ont::LibraryFactory.new({})
        factory.save
        expect(Ont::Library.all.count).to eq(0)
      end

      it 'does not create any tubes' do
        factory = Ont::LibraryFactory.new({})
        factory.save
        expect(Tube.all.count).to eq(0)
      end

      it 'does not create any container materials' do
        current_count = ContainerMaterial.count
        factory = Ont::LibraryFactory.new({})
        factory.save
        expect(ContainerMaterial.all.count).to eq(current_count)
      end
    end
  end
end
