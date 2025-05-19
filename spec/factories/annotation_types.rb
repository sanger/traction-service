# frozen_string_literal: true

FactoryBot.define do
  factory :annotation_type do
    sequence(:name) { |n| "Annotation Type #{n}" }
  end
end
