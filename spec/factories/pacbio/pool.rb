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

    factory :pacbio_pool_with_used_aliquots do
      transient do
        aliquot_count { 2 }
        used_aliquot_factory { :aliquot }
        aliquot_source { association(:pacbio_request) }
      end

      libraries { [] }
      used_aliquots { build_list(used_aliquot_factory, aliquot_count, source: aliquot_source, aliquot_type: :derived, used_by: instance) }
    end
  end
end
