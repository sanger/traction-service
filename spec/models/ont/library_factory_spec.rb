require 'rails_helper'

RSpec.describe Ont::PlateFactory, type: :model, ont: true do
  let!(:plate) { create(:plate_with_wells, row_count: 3, column_count: 3) }

  context '#initialise' do
    let!(:tag_set) { create(:tag_set_with_tags, number_of_tags: 9) }
    let!(:well_primary_grouping_direction) { 'vertical' }

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

    it 'is not valid with no wells or tags' do
      attributes = {
        plate_barcode: create(:plate).barcode,
        tag_set_name: create(:tag_set).name,
        well_primary_grouping_direction: 'vertical'
      }
      factory = Ont::LibraryFactory.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end
  end

  context '#save' do
    context 'valid build' do
      context 'with empty wells' do
        let!(:tag_set) { create(:tag_set_with_tags, number_of_tags: 9) }
        let!(:attributes) { { plate_barcode: plate.barcode, tag_set_name: tag_set.name, well_primary_grouping_direction: 'vertical' } }

        it 'creates expected library' do
          factory = Ont::LibraryFactory.new(attributes)
          factory.save
          expect(Ont::Library.count).to eq(1)
          expect(Ont::Library.first.name).to eq("#{plate.barcode}-1")
          expect(Ont::Library.first.plate_barcode).to eq(plate.barcode)
          expect(Ont::Library.first.well_range).to eq('A1-C3')
          expect(Ont::Library.first.pool).to eq(1)
          expect(Ont::Library.first.pool_size).to eq(9)
        end

        it 'creates and exposes a tube that contains the library' do
          factory = Ont::LibraryFactory.new(attributes)
          factory.save
          expect(Tube.count).to eq(1)
          expect(factory.tubes).to match_array(Tube.all)
          expect(Tube.first.materials.count).to eq(1)
          expect(Tube.first.materials).to contain_exactly(Ont::Library.first)
        end

        it 'does not create any library_request joins' do
          factory = Ont::LibraryFactory.new(attributes)
          factory.save
          expect(Ont::LibraryRequest.count).to eq(0)
        end

        context 'validates' do
          it 'each library exactly once' do
            validation_count = 0
            allow_any_instance_of(Ont::Library).to receive(:valid?) { |_| validation_count+=1 }
            factory = Ont::LibraryFactory.new(attributes)
            factory.save
            expect(validation_count).to eq(Ont::Library.count)
          end

          it 'each library request exactly once' do
            validation_count = 0
            allow_any_instance_of(Ont::LibraryRequest).to receive(:valid?) { |_| validation_count+=1 }
            factory = Ont::LibraryFactory.new(attributes)
            factory.save
            expect(validation_count).to eq(Ont::LibraryRequest.count)
          end

          it 'each tube exactly once' do
            validation_count = 0
            allow_any_instance_of(Tube).to receive(:valid?) { |_| validation_count+=1 }
            factory = Ont::LibraryFactory.new(attributes)
            factory.save
            expect(validation_count).to eq(Tube.count)
          end

          it 'each tube container_material exactly once' do
            validation_count = 0
            allow_any_instance_of(ContainerMaterial).to receive(:valid?) { |_| validation_count+=1 }
            factory = Ont::LibraryFactory.new(attributes)
            factory.save
            #
            expect(validation_count).to eq(Tube.count)
          end
        end
      end
      
      context 'with filled wells' do
        let!(:plate_with_requests) { create(:plate_with_ont_samples, barcode: 'PLATE-1234', wells: [
          { position: 'A1', samples: [ { name: 'Sample 1 for A1', external_id: 'ExtIdA1-1' }, { name: 'Sample 2 for A1', external_id: 'ExtIdA1-2' } ] },
          { position: 'A2', samples: [ { name: 'Sample for A2', external_id: 'ExtIdA2' } ] },
          { position: 'A3', samples: [ { name: 'Sample for A3', external_id: 'ExtIdA3' } ] },
          { position: 'B3', samples: [ { name: 'Sample for B3', external_id: 'ExtIdB3' } ] },
          { position: 'B2', samples: [ { name: 'Sample for B2', external_id: 'ExtIdB2' } ] },
          { position: 'B1', samples: [ { name: 'Sample for B1', external_id: 'ExtIdB1' } ] },
          { position: 'C2', samples: [ { name: 'Sample 1 for C2', external_id: 'ExtIdC2-1' }, { name: 'Sample 2 for C2', external_id: 'ExtIdC2-2' } ] },
          { position: 'C1', samples: [ { name: 'Sample for C1', external_id: 'ExtIdC1' } ] },
          { position: 'C3', samples: [ { name: 'Sample for C3', external_id: 'ExtIdC3' } ] } ])
        }

        context 'with one tag set iteration' do
          let!(:tag_set) { create(:tag_set_with_tags, number_of_tags: 9) }
          let!(:attributes) { { plate_barcode: plate_with_requests.barcode, tag_set_name: tag_set.name, well_primary_grouping_direction: 'vertical' } }

          it 'creates expected library' do
            factory = Ont::LibraryFactory.new(attributes)
            factory.save
            expect(Ont::Library.count).to eq(1)
            expect(Ont::Library.first.name).to eq("#{plate_with_requests.barcode}-1")
            expect(Ont::Library.first.plate_barcode).to eq(plate_with_requests.barcode)
            expect(Ont::Library.first.well_range).to eq('A1-C3')
            expect(Ont::Library.first.pool).to eq(1)
            expect(Ont::Library.first.pool_size).to eq(9)
          end

          it 'creates and exposes a tube that contains the library' do
            factory = Ont::LibraryFactory.new(attributes)
            factory.save
            expect(Tube.count).to eq(1)
            expect(factory.tubes).to match_array(Tube.all)
            expect(Tube.first.materials.count).to eq(1)
            expect(Tube.first.materials).to contain_exactly(Ont::Library.first)
          end

          it 'creates expected library_request joins' do
            factory = Ont::LibraryFactory.new(attributes)
            factory.save
            # sanity check
            expect(Ont::Request.count).to eq(11)
            expect(Tag.count).to eq(9)
            # test requests are tagged correctly
            library = Ont::Library.first              
            ['A1', 'B1', 'C1', 'A2', 'B2', 'C2', 'A3', 'B3', 'C3'].each_with_index do |position, idx|
              tag = tag_set.tags[idx]
              plate_with_requests.wells.find_by(position: position).materials.each do |request|
                expect(Ont::LibraryRequest.where(library: library, request: request, tag: tag).count).to eq(1)
              end
            end
          end

          context 'validates' do
            it 'each library exactly once' do
              validation_count = 0
              allow_any_instance_of(Ont::Library).to receive(:valid?) { |_| validation_count+=1 }
              factory = Ont::LibraryFactory.new(attributes)
              factory.save
              expect(validation_count).to eq(Ont::Library.count)
            end
  
            it 'each library request exactly once' do
              validation_count = 0
              allow_any_instance_of(Ont::LibraryRequest).to receive(:valid?) { |_| validation_count+=1 }
              factory = Ont::LibraryFactory.new(attributes)
              factory.save
              expect(validation_count).to eq(Ont::LibraryRequest.count)
            end
  
            it 'each tube exactly once' do
              validation_count = 0
              allow_any_instance_of(Tube).to receive(:valid?) { |_| validation_count+=1 }
              factory = Ont::LibraryFactory.new(attributes)
              factory.save
              expect(validation_count).to eq(Tube.count)
            end
  
            it 'each tube container_material exactly once' do
              validation_count = 0
              allow_any_instance_of(ContainerMaterial).to receive(:valid?) { |_| validation_count+=1 }
              factory = Ont::LibraryFactory.new(attributes)
              factory.save
              expect(validation_count).to eq(Tube.count)
            end
          end
        end
  
        context 'with many tag set iterations' do
          let!(:tag_set) { create(:tag_set_with_tags, number_of_tags: 3) }
          let!(:attributes) { { plate_barcode: plate_with_requests.barcode, tag_set_name: tag_set.name, well_primary_grouping_direction: 'horizontal' } }

          it 'creates expected libraries' do
            factory = Ont::LibraryFactory.new(attributes)
            factory.save
            expect(Ont::Library.count).to eq(3)
            expect(Ont::Library.all.map { |lib| lib.pool_size  }).to all( eq(3) )

            expect(Ont::Library.first.name).to eq("#{plate_with_requests.barcode}-1")
            expect(Ont::Library.first.plate_barcode).to eq(plate_with_requests.barcode)
            expect(Ont::Library.first.pool).to eq(1)
            expect(Ont::Library.first.well_range).to eq('A1-A3')

            expect(Ont::Library.second.name).to eq("#{plate_with_requests.barcode}-2")
            expect(Ont::Library.second.plate_barcode).to eq(plate_with_requests.barcode)
            expect(Ont::Library.second.pool).to eq(2)
            expect(Ont::Library.second.well_range).to eq('B1-B3')

            expect(Ont::Library.third.name).to eq("#{plate_with_requests.barcode}-3")
            expect(Ont::Library.third.plate_barcode).to eq(plate_with_requests.barcode)
            expect(Ont::Library.third.pool).to eq(3)
            expect(Ont::Library.third.well_range).to eq('C1-C3')
          end

          it 'creates and exposes tubes for each library' do
            factory = Ont::LibraryFactory.new(attributes)
            factory.save
            expect(Tube.count).to eq(3)
            expect(factory.tubes).to match_array(Tube.all)
            # test each tube has one material AND all tubes contain all libraries => each library exists in a different tube
            expect(Tube.all.map { |tube| tube.materials.count }).to all( eq(1) )
            expect(Tube.all.map { |tube| tube.materials }.flatten).to match_array(Ont::Library.all)
          end

          it 'creates expected library_request joins' do
            factory = Ont::LibraryFactory.new(attributes)
            factory.save
            # sanity check
            expect(Ont::Request.count).to eq(11)
            expect(Tag.count).to eq(3)
            # test requests are tagged correctly
            ['A', 'B', 'C'].each_with_index do |row, row_idx|
              library = Ont::Library.all[row_idx]
              (1..3).each do |col|
                position = "#{row}#{col}"
                tag = tag_set.tags[col - 1]
                plate_with_requests.wells.find_by(position: position).materials.each do |request|
                  expect(Ont::LibraryRequest.where(library: library, request: request, tag: tag).count).to eq(1)
                end
              end
            end
          end

          context 'validates' do
            it 'each library exactly once' do
              validation_count = 0
              allow_any_instance_of(Ont::Library).to receive(:valid?) { |_| validation_count+=1 }
              factory = Ont::LibraryFactory.new(attributes)
              factory.save
              expect(validation_count).to eq(Ont::Library.count)
            end
  
            it 'each library request exactly once' do
              validation_count = 0
              allow_any_instance_of(Ont::LibraryRequest).to receive(:valid?) { |_| validation_count+=1 }
              factory = Ont::LibraryFactory.new(attributes)
              factory.save
              expect(validation_count).to eq(Ont::LibraryRequest.count)
            end
  
            it 'each tube exactly once' do
              validation_count = 0
              allow_any_instance_of(Tube).to receive(:valid?) { |_| validation_count+=1 }
              factory = Ont::LibraryFactory.new(attributes)
              factory.save
              expect(validation_count).to eq(Tube.count)
            end
  
            it 'each tube container_material exactly once' do
              validation_count = 0
              allow_any_instance_of(ContainerMaterial).to receive(:valid?) { |_| validation_count+=1 }
              factory = Ont::LibraryFactory.new(attributes)
              factory.save
              expect(validation_count).to eq(Tube.count)
            end
          end
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

      it 'does not create any tag taggables' do
        factory = Ont::LibraryFactory.new({})
        factory.save
        expect(TagTaggable.all.count).to eq(0)
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
        factory = Ont::LibraryFactory.new({})
        factory.save
        expect(ContainerMaterial.all.count).to eq(0)
      end
    end
  end
end
