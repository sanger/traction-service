# frozen_string_literal: true

FactoryBot.define do
  factory :tag_taggable do
    tag
    taggable { association :pacbio_request }
  end
end
