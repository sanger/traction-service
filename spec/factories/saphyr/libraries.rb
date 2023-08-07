# frozen_string_literal: true

FactoryBot.define do
  factory :saphyr_library, class: 'Saphyr::Library' do
    state { 'pending' }
    request { association :saphyr_request }
    enzyme { association :saphyr_enzyme }

    factory :library_no_state do
      state { nil }
    end

    factory :saphyr_library_in_tube do
      after :create do |library|
        tube = create(:tube)
        create(:container_material, container: tube, material: library)
      end
    end
  end
end
