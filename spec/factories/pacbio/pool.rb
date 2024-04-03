# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_pool, class: 'Pacbio::Pool' do
    transient do
      library_count { 1 }
      library_factory { :pacbio_library }
    end

    primary_aliquot { association :aliquot, source: instance, aliquot_type: :primary }
    template_prep_kit_box_barcode { 'ABC1' }
    concentration { 10 }
    volume { 10 }
    insert_size { 100 }

    used_aliquots { build_list(:aliquot, library_count, source: build(library_factory), aliquot_type: :derived, used_by: instance) }

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
