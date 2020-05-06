# frozen_string_literal: true

module Ont
  # Ont::LibraryRequest
  class LibraryRequest < ApplicationRecord
    include Taggable

    belongs_to :library, foreign_key: :ont_library_id, inverse_of: :library_requests, dependent: :destroy
    belongs_to :request, foreign_key: :ont_request_id, inverse_of: :library_requests
  end
end
