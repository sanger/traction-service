# frozen_string_literal: true

module Ont
  # Ont::Library
  class Library < ApplicationRecord
    include Material

    has_many :requests, foreign_key: :ont_library_id, inverse_of: :library, dependent: :destroy

    validates :name, :pool, :well_range, :pool_size, presence: true
  end
end
