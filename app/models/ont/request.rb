# frozen_string_literal: true

module Ont
  # Ont::Request
  class Request < ApplicationRecord
    include Material
    include Taggable

    belongs_to :library, foreign_key: :ont_library_id, inverse_of: :requests,
                         dependent: :destroy, optional: true
    validates :name, :external_id, presence: true
  end
end
