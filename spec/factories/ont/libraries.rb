FactoryBot.define do
  factory :ont_library, class: 'Ont::Library' do
    plate_barcode { "PLATE-1-123456" }
    pool { 2 }
    well_range { "A1-H8" }
    pool_size { 24 }

    factory :ont_library_with_requests do
      transient do
        requests_count { 2 }
      end   

      after(:create) do |library, evaluator|
        create_list(:ont_request, evaluator.requests_count, library: library)
      end
    end
  end
end
