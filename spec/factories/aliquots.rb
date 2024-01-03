# frozen_string_literal: true

FactoryBot.define do
  factory :aliquot do
    volume { 1.5 }
    concentration { 10 }
    template_prep_kit_box_barcode { 'ABC123' }
    tag
    source { association(:pacbio_library) }
  end
end
