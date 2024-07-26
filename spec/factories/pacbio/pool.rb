# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_pool, class: 'Pacbio::Pool' do
    transient do
      library_count { 1 }
      library_factory { :pacbio_library }
    end

    primary_aliquot { association :aliquot, source: instance, aliquot_type: :primary, volume: 10 }
    template_prep_kit_box_barcode { 'ABC1' }
    concentration { 10 }
    volume { 10 }
    insert_size { 100 }

    used_aliquots do
      library_count.times.map do
        library = build(library_factory)
        build(:aliquot, source: library, tag: library.tag, aliquot_type: :derived, used_by: instance)
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

    trait :hidden_tagged do
      transient do
        library_count { 1 }
        library_factory { :pacbio_library_with_hidden_tag }
      end
    end
  end
end
