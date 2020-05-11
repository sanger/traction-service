FactoryBot.define do
  factory :plate do
    factory :plate_with_wells do
      transient do
        well_count { 1 }
      end
  
      after :create do |plate, options|
        options.well_count.times do |i|
          create(:well, position: "A#{i}", plate: plate)
        end
      end
    end

    factory :plate_with_ont_requests do
      transient do
        wells { [ { position: 'A1', requests: [ { name: 'Sample in A1' } ] } ] }
      end
  
      after :create do |plate, options|
        options.wells.each do |well_spec|
          well = create(:well_with_ont_requests, plate: plate, position: well_spec[:position], requests: well_spec[:requests])
        end
      end
    end
  end
end
