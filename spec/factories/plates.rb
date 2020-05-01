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

    factory :plate_with_ont_samples do
      transient do
        wells { [ { position: 'A1', samples: [ { name: 'Sample in A1' } ] } ] }
      end
  
      after :create do |plate, options|
        options.wells.each do |well_spec|
          well = create(:well_with_ont_samples, plate: plate, position: well_spec[:position], samples: well_spec[:samples])
        end
      end
    end
  end
end
