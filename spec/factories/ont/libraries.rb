FactoryBot.define do
  factory :ont_library, class: 'Ont::Library' do
    name { "PLATE-1-123456-2" }
    pool { 2 }
    pool_size { 24 }
    
    factory :ont_library_in_tube do
      after(:create) do |library|
        create(:container_material, material: library, container: create(:tube))
      end
    end

    factory :ont_library_with_requests do
      requests { [create(:ont_request)] }
    end
  end
end
