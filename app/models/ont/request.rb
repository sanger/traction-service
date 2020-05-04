# frozen_string_literal: true

module Ont
  # Ont::Request
  class Request < ApplicationRecord
    include Material
    include Taggable

    belongs_to :library, class_name: 'Ont::Library', foreign_key: :ont_library_id,
                         inverse_of: :requests, optional: true

    has_one :request, class_name: '::Request', as: :requestable, dependent: :nullify
    has_one :sample, through: :request

    validates :external_study_id, presence: true

    delegate :name, to: :sample, prefix: :sample
    delegate :species, to: :sample, prefix: :sample
  end
end
