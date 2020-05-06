# frozen_string_literal: true

module Ont
  # Ont::Request
  class Request < ApplicationRecord
    include Material
    include Taggable

    has_one :request, class_name: '::Request', as: :requestable, dependent: :nullify
    has_one :sample, through: :request
    has_many :library_requests, foreign_key: :ont_request_id, inverse_of: :request, dependent: :destroy

    validates :external_study_id, presence: true

    delegate :name, to: :sample, prefix: :sample
    delegate :species, to: :sample, prefix: :sample
  end
end
