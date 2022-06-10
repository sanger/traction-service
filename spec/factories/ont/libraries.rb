# frozen_string_literal: true

FactoryBot.define do
  factory :ont_library, class: 'Ont::Library' do
    sequence(:pool) { |n| n }
    name { "PLATE-1-123456-#{pool}" }
    pool_size { 24 }

    factory :ont_library_in_tube do
      after(:create) do |library|
        create(:container_material, material: library, container: create(:tube))
      end
    end
  end
end
