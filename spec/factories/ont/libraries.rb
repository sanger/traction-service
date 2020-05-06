FactoryBot.define do
  factory :ont_library, class: 'Ont::Library' do
    name { "PLATE-1-123456-2" }
    plate_barcode { "PLATE-1-123456" }
    pool { 2 }
    well_range { "A1-H8" }
    pool_size { 24 }
    
    factory :ont_library_in_tube do
      after(:create) do |library|
        create(:container_material, material: library, container: create(:tube))
      end
    end
  end
end
