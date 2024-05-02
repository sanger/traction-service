# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_library, class: 'Pacbio::Library' do
    volume { 1.111 }
    concentration { 2.222 }
    template_prep_kit_box_barcode { 'LK1234567' }
    insert_size { 100 }
    request { association :pacbio_request }
    tag
    tube { nil }
    primary_aliquot { association :aliquot, source: instance, aliquot_type: :primary, volume:, concentration: }
    used_aliquots { build_list(:aliquot, 1, source: request, tag:, aliquot_type: :derived, used_by: instance) }

    factory :pacbio_incomplete_library do
      insert_size { nil }
    end

    # Untagged should possibly be the default
    factory :pacbio_library_without_tag do
      untagged
    end

    factory :pacbio_library_with_tag do
      tagged
    end

    factory :pacbio_library_with_hidden_tag do
      hidden_tagged
    end

    trait :tagged do
      tag
    end

    trait :untagged do
      tag { nil }
    end

    trait :hidden_tagged do
      tag { association :hidden_tag }
    end
  end
end
