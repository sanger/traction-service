# frozen_string_literal: true

FactoryBot.define do
  factory :tag_set do
    sequence(:name) { |n| "Tag-Set-#{n}" }
    sequence(:uuid) { |n| n }
    pipeline { :pacbio }

    factory :hidden_tag_set do
      sample_sheet_behaviour { :hidden }
    end

    factory :ont_tag_set do
      pipeline { :ont }
    end

    factory :tag_set_with_tags do
      transient do
        number_of_tags { 3 }
      end

      after :create do |tag_set, options|
        options.number_of_tags.times do
          create(:tag, tag_set:)
        end
      end
    end
  end
end
