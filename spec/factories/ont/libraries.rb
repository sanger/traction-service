# frozen_string_literal: true

FactoryBot.define do
  factory :ont_library, class: 'Ont::Library' do
    volume { 1.111 }
    concentration { 10.0 }
    insert_size { 10000 }
    kit_barcode { 'kit_barcode' }
    request { create(:ont_request) }
    tag { create(:tag) }
    pool { association :ont_pool, libraries: [instance] }

    factory :ont_library_in_tube do
      after(:create) do |library|
        create(:container_material, material: library, container: create(:tube))
      end
    end

    factory :ont_library_without_tag do
      untagged
    end

    factory :ont_library_with_tag do
      tagged
    end

    trait :tagged do
      tag
    end

    trait :untagged do
      tag { nil }
    end
  end
end
