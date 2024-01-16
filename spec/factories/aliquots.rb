# frozen_string_literal: true

FactoryBot.define do
  factory :aliquot do
    volume { 1.5 }
    concentration { 10 }
    template_prep_kit_box_barcode { 'ABC123' }
    insert_size { 100 }
    tag
    source { association(:pacbio_library) }

    trait :primary do
      aliquot_type { :primary }
    end
  end
end
