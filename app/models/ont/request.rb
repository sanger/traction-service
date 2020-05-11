# frozen_string_literal: true

module Ont
  # Ont::Request
  class Request < ApplicationRecord
    include Material
    include Taggable

    has_one :library_request, foreign_key: :ont_request_id,
                              inverse_of: :request, dependent: :destroy
    validates :name, :external_id, presence: true
  end
end
