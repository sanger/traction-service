FactoryBot.define do
  factory :pacbio_library, class: Pacbio::Library do
    volume { 1.111 }
    concentration { 2.222 }
    template_prep_kit_box_barcode { 'LK1234567' }
    insert_size { 100 }
    request { create(:pacbio_request) }
    tag { create(:tag) }
    pool { association :pacbio_pool, libraries: [instance] }

    # Untagged should possibly be the default
    factory :pacbio_library_without_tag do
      untagged
    end

    factory :pacbio_library_with_tag do
      tagged
    end

    factory :pacbio_library_in_tube do
      after :create do |library|
        tube = create(:tube)
        create(:container_material, container: tube, material: library)
      end
    end

    trait :tagged do
      tag
    end

    trait :untagged do
      tag { nil }
    end
  end
end
