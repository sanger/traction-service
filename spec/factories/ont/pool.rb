# frozen_string_literal: true

FactoryBot.define do
  factory :ont_pool, class: 'Ont::Pool' do
    transient do
      library_count { 1 }
      library_factory { :ont_library }
    end

    libraries { build_list(library_factory, library_count, pool: instance) }
    volume { 10 }
    kit_number { 100 }

    trait :tagged do
      transient do
        library_count { 2 }
        library_factory { :ont_library_with_tag }
      end
    end

    trait :untagged do
      transient do
        library_count { 1 }
        library_factory { :ont_library_without_tag }
      end
    end
  end
end
