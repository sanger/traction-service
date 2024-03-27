# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_pool, class: 'Pacbio::Pool' do
    transient do
      library_count { 1 }
      library_factory { :pacbio_library }
    end
    libraries { build_list(library_factory, library_count, pool: instance) }
    primary_aliquot { association :aliquot, source: instance, aliquot_type: :primary }
    template_prep_kit_box_barcode { 'ABC1' }
    concentration { 10 }
    volume { 10 }
    insert_size { 100 }

    after(:build) do |pool|
      pool.libraries.each do |lib|
        pool.used_aliquots << build(:aliquot, source: lib.request, aliquot_type: :derived, used_by: pool)
      end
    end

    trait :tagged do
      transient do
        library_count { 2 }
        library_factory { :pacbio_library_with_tag }
      end
    end

    trait :untagged do
      transient do
        library_count { 1 }
        library_factory { :pacbio_library_without_tag }
      end
    end
  end
end
