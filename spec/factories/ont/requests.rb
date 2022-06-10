# frozen_string_literal: true

FactoryBot.define do
  factory :ont_request, class: 'Ont::Request' do
    external_study_id
    cost_code
  end
end
