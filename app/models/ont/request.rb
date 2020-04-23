# frozen_string_literal: true

module Ont
  # Ont::Request
  class Request < ApplicationRecord
    include Material

    has_one :request, class_name: '::Request', as: :requestable, dependent: :nullify
    has_one :sample, through: :request

    validates :external_study_id, presence: true

    delegate :name, to: :sample, prefix: :sample
  end
end
