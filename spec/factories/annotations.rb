# frozen_string_literal: true

FactoryBot.define do
  factory :annotation do
    comment { 'Rabbit, rabbit, chat chat rabbit' }
    user { 'aa1' }
    annotation_type
    annotatable { association(:pacbio_revio_run) }
  end
end
