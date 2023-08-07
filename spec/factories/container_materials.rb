# frozen_string_literal: true

FactoryBot.define do
  factory :container_material do
    container { association :well }
    material { association :pacbio_request }
  end
end
