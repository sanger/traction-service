# frozen_string_literal: true

FactoryBot.define do
  factory :request do
    sample
    requestable { create(:pacbio_request) }
  end
end
