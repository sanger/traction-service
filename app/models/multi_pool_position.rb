# frozen_string_literal: true

# MultiPoolPosition
# An instance of a pool in a MultiPool at a specific position.
class MultiPoolPosition < ApplicationRecord
  belongs_to :pool, polymorphic: true
  belongs_to :multi_pool

  validates :position, presence: true
end
