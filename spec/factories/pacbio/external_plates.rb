# frozen_string_literal: true

FactoryBot.define do
  factory :external_plate, class: 'Hash' do
    transient do
      rows { %w[A B C D E F G H] }
      columns { 12 }
      samples { build_list(:external_sample, 48) }
    end

    sequence(:barcode) { |n| "DN#{n}" }
    wells do
      sample_list = samples.dup
      rows.flat_map do |row|
        (1..columns).map do |column|
          # this is easier than constructing our own sample as they will be unique
          # if we pop the sample off each time no need to count
          # if the samples are empty then no need to pop anymore
          # attributes will contain things like id etc so we need to remove anything that is nil
          sample = sample_list.pop
          {
            position: "#{row}#{column}",
            samples: sample ? [sample] : nil
          }.compact
        end
      end
    end

    initialize_with { attributes }

    skip_create
  end
end
