FactoryBot.define do
  factory :plate do
    factory :plate_with_wells do
      transient do
        row_count { 1 }
        column_count { 3 }
      end
  
      after :create do |plate, options|
        fail if options.row_count > 8
        ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'].first(options.row_count).each do |row|
          (1..options.column_count).each do |col|
            create(:well, position: "#{row}#{col}", plate: plate)
          end
        end
      end

      factory :plate_with_wells_and_requests do

        transient do
          pipeline { 'ont' }
        end

        after :create do |plate, options|
          plate.wells.each do |well|
            create(:container_material, container: well, material: create("#{options.pipeline}_request".to_sym))
          end
        end
      end
    end

    factory :plate_with_ont_requests do
      transient do
        wells { [ { position: 'A1', requests: [ { name: 'Sample in A1' } ] } ] }
      end
  
      after :create do |plate, options|
        options.wells.each do |well_spec|
          plate.wells << create(:well_with_ont_requests, plate: plate, position: well_spec[:position], requests: well_spec[:requests])
        end
      end
    end

    factory :plate_with_tagged_ont_requests do
      transient do
        row_count { 1 }
        column_count { 3 }
      end
  
      after :create do |plate, options|
        fail if options.row_count > 8
        ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'].first(options.row_count).each do |row|
          (1..options.column_count).each do |col|
            create(:well_with_tagged_ont_requests, position: "#{row}#{col}", plate: plate)
          end
        end
      end
    end
  end
end
