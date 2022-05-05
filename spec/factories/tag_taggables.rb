# frozen_string_literal: true

FactoryBot.define do
  factory :tag_taggable do
    tag { create(:tag) }
    taggable { create(:pacbio_request) }
  end
end
