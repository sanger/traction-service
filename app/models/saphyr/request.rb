# frozen_string_literal: true

module Saphyr
  # Request
  class Request < ApplicationRecord
    include Material

    validates :external_study_id, presence: true

    belongs_to :request, polymorphic: true, optional: true
    has_one :request, class_name: '::Request', as: :requestable, dependent: :nullify
    has_one :sample, through: :request

    delegate :name, to: :sample, prefix: :sample
  end
end
